"""
tests/test_preferences.py
──────────────────────────
Unit & integration tests for PUT /api/users/preferences (Task 4).
Runs strictly against an isolated in-memory SQLite database.
"""
from __future__ import annotations

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.core.deps import get_db
from app.core.limiter import limiter
from app.db.models import Base
from main import app


@pytest.fixture()
def client():
    # Use isolated in-memory SQLite for testing; never touches remote Supabase
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(engine)
    TestingSession = sessionmaker(bind=engine, autoflush=False, expire_on_commit=False)

    def override_get_db():
        db = TestingSession()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_db] = override_get_db
    limiter.enabled = False

    with TestClient(app, raise_server_exceptions=True) as c:
        yield c

    app.dependency_overrides.clear()
    limiter.enabled = True


def _register_user(client: TestClient, email: str = "prefuser@example.com") -> tuple[str, dict]:
    """Helper to register a new user and return (token, auth_headers)."""
    resp = client.post(
        "/api/auth/register",
        json={
            "full_name": "Preference User",
            "identifier": email,
            "password": "ValidPassword123",
        },
    )
    assert resp.status_code == 201
    token = resp.json()["data"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    return token, headers


# ─── 1. Valid full payload -> 204, then GET /me shows has_preferences: True ───

def test_valid_full_payload_and_me_has_preferences(client):
    _, headers = _register_user(client, "full_pref@example.com")

    # Before PUT: has_preferences must be False
    me_before = client.get("/api/users/me", headers=headers)
    assert me_before.status_code == 200
    assert me_before.json()["data"]["has_preferences"] is False

    payload = {
        "persona": "visitor",
        "purpose": "tourism",
        "stay_length": "few_days",
        "interests": ["historical", "nubian", "nature", "food"],
        "travel_styles": ["calm", "cultural"],
        "companions": "solo",
        "needs": ["finding_places"],
        "language": "en",
    }
    resp = client.put("/api/users/preferences", json=payload, headers=headers)
    assert resp.status_code == 204
    assert resp.content == b""

    # After PUT: has_preferences must be True
    me_after = client.get("/api/users/me", headers=headers)
    assert me_after.status_code == 200
    assert me_after.json()["data"]["has_preferences"] is True


# ─── 2. All fields null / empty lists -> 204 ─────────────────────────────────

def test_all_fields_null_and_empty_lists(client):
    _, headers = _register_user(client, "null_pref@example.com")

    # Before PUT: has_preferences is False
    me_before = client.get("/api/users/me", headers=headers)
    assert me_before.status_code == 200
    assert me_before.json()["data"]["has_preferences"] is False

    payload = {
        "persona": None,
        "purpose": None,
        "stay_length": None,
        "interests": [],
        "travel_styles": [],
        "companions": None,
        "needs": [],
        "language": None,
    }
    resp = client.put("/api/users/preferences", json=payload, headers=headers)
    assert resp.status_code == 204

    # Row is created, has_preferences becomes True
    me = client.get("/api/users/me", headers=headers)
    assert me.status_code == 200
    assert me.json()["data"]["has_preferences"] is True

    # Check that lists are stored as empty lists
    prefs = client.get("/api/users/preferences", headers=headers)
    assert prefs.status_code == 200
    pref_data = prefs.json()["data"]
    assert pref_data["interests"] == []
    assert pref_data["travel_styles"] == []
    assert pref_data["needs"] == []


# ─── 3. Invalid persona ("alien") -> 422 VALIDATION_ERROR ────────────────────

def test_invalid_persona_returns_422_validation_error(client):
    _, headers = _register_user(client, "alien_pref@example.com")

    resp = client.put(
        "/api/users/preferences",
        json={"persona": "alien"},
        headers=headers,
    )
    assert resp.status_code == 422
    body = resp.json()
    assert "error" in body
    assert body["error"]["code"] == "VALIDATION_ERROR"
    assert "persona" in body["error"]["details"]


# ─── 4. Duplicate list items are stored once ─────────────────────────────────

def test_duplicate_list_items_stored_once(client):
    _, headers = _register_user(client, "dedup_pref@example.com")

    payload = {
        "interests": ["food", "food", "historical", "food", "nubian"],
        "travel_styles": ["calm", "calm", "cultural"],
        "needs": ["finding_places", "finding_places"],
    }
    resp = client.put("/api/users/preferences", json=payload, headers=headers)
    assert resp.status_code == 204

    # Read back preferences to verify deduplication and order preservation
    prefs_resp = client.get("/api/users/preferences", headers=headers)
    assert prefs_resp.status_code == 200
    data = prefs_resp.json()["data"]
    assert data["interests"] == ["food", "historical", "nubian"]
    assert data["travel_styles"] == ["calm", "cultural"]
    assert data["needs"] == ["finding_places"]


# ─── 5. Calling PUT twice replaces previous values ───────────────────────────

def test_put_twice_replaces_previous_values(client):
    _, headers = _register_user(client, "replace_pref@example.com")

    # First PUT
    first_payload = {
        "persona": "visitor",
        "purpose": "tourism",
        "interests": ["historical", "nature"],
        "language": "en",
    }
    r1 = client.put("/api/users/preferences", json=first_payload, headers=headers)
    assert r1.status_code == 204

    read1 = client.get("/api/users/preferences", headers=headers).json()["data"]
    assert read1["persona"] == "visitor"
    assert read1["purpose"] == "tourism"
    assert read1["interests"] == ["historical", "nature"]

    # Second PUT: completely replaces previous values
    second_payload = {
        "persona": "resident",
        "purpose": "living",
        "interests": ["food"],
        "language": "ar",
    }
    r2 = client.put("/api/users/preferences", json=second_payload, headers=headers)
    assert r2.status_code == 204

    read2 = client.get("/api/users/preferences", headers=headers).json()["data"]
    assert read2["persona"] == "resident"
    assert read2["purpose"] == "living"
    assert read2["interests"] == ["food"]  # "historical" and "nature" are replaced
    assert read2["language"] == "ar"


# ─── 6. No token -> 401 with code UNAUTHORIZED ───────────────────────────────

def test_no_token_returns_401_unauthorized(client):
    resp = client.put(
        "/api/users/preferences",
        json={"persona": "visitor"},
    )
    assert resp.status_code == 401
    body = resp.json()
    assert "error" in body
    assert body["error"]["code"] == "UNAUTHORIZED"
