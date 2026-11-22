"""
tests/test_demo_mode.py
Tests for S13 (DEMO_MODE flag) and S4 (demo code stored hashed).
Uses in-memory SQLite. No real database and no real email is used.
"""
from __future__ import annotations

import os

# Point the app at SQLite BEFORE importing any app module (never touch the real database).
os.environ.setdefault("DATABASE_URL", "sqlite:///./test_demo.db")
os.environ.setdefault("JWT_SECRET_KEY", "test-secret-key-must-be-at-least-32-chars-long")
os.environ.setdefault("APP_SECRET_KEY", "test-app-secret-key-at-least-32-ch")
os.environ.setdefault("RESET_CODE_SECRET", "test-reset-hmac-secret")

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.core.deps import get_db
from app.core.limiter import limiter
from app.db.models import Base
from main import app

DEMO_EMAIL = "laila@example.com"
DEMO_PASSWORD = "DemoPass2026"
NEW_PASSWORD = "NewSecure99"


@pytest.fixture()
def client(monkeypatch):
    """Isolated in-memory SQLite client. Rate limiter and email sending are disabled."""
    # Never send a real email from tests
    monkeypatch.setattr("app.routers.auth.send_reset_code", lambda *a, **k: None)

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


def _register_demo_user(client: TestClient) -> None:
    resp = client.post(
        "/api/auth/register",
        json={"full_name": "Laila Hassan", "identifier": DEMO_EMAIL, "password": DEMO_PASSWORD},
    )
    assert resp.status_code in (201, 409)


def test_demo_code_rejected_when_demo_mode_false(client, monkeypatch):
    """DEMO_MODE=false: the fixed code 1234 must NOT work for the demo account."""
    from app.core import config as cfg
    monkeypatch.setattr(cfg.settings, "DEMO_MODE", False)
    monkeypatch.setattr(cfg.settings, "SEED_DEMO_EMAIL", DEMO_EMAIL)

    _register_demo_user(client)
    r_forgot = client.post("/api/auth/forgot-password", json={"identifier": DEMO_EMAIL})
    assert r_forgot.status_code == 204  # contract: 204

    r_reset = client.post(
        "/api/auth/reset-password",
        json={"identifier": DEMO_EMAIL, "code": "1234", "new_password": NEW_PASSWORD},
    )
    assert r_reset.status_code == 422
    assert r_reset.json()["error"]["code"] == "INVALID_CODE"


def test_demo_code_accepted_when_demo_mode_true(client, monkeypatch):
    """DEMO_MODE=true: the fixed code 1234 works for the demo account only."""
    from app.core import config as cfg
    monkeypatch.setattr(cfg.settings, "DEMO_MODE", True)
    monkeypatch.setattr(cfg.settings, "SEED_DEMO_EMAIL", DEMO_EMAIL)

    _register_demo_user(client)
    r_forgot = client.post("/api/auth/forgot-password", json={"identifier": DEMO_EMAIL})
    assert r_forgot.status_code == 204

    r_reset = client.post(
        "/api/auth/reset-password",
        json={"identifier": DEMO_EMAIL, "code": "1234", "new_password": NEW_PASSWORD},
    )
    assert r_reset.status_code == 204


def test_demo_code_never_works_for_other_users(client, monkeypatch):
    """Even with DEMO_MODE=true, 1234 must not work for a normal account."""
    from app.core import config as cfg
    monkeypatch.setattr(cfg.settings, "DEMO_MODE", True)
    monkeypatch.setattr(cfg.settings, "SEED_DEMO_EMAIL", DEMO_EMAIL)

    other = "someone@example.com"
    client.post(
        "/api/auth/register",
        json={"full_name": "Some One", "identifier": other, "password": DEMO_PASSWORD},
    )
    assert client.post("/api/auth/forgot-password", json={"identifier": other}).status_code == 204

    r_reset = client.post(
        "/api/auth/reset-password",
        json={"identifier": other, "code": "1234", "new_password": NEW_PASSWORD},
    )
    assert r_reset.status_code == 422
    assert r_reset.json()["error"]["code"] == "INVALID_CODE"