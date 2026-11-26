"""
tests/test_api_integration.py
──────────────────────────────
Comprehensive integration tests for Aswani API (Sprint 1 & Sprint 2).
Executes against an in-memory SQLite database using FastAPI TestClient.
"""
from __future__ import annotations

import io
from datetime import date, timedelta
import pytest
from fastapi.testclient import TestClient

from main import app
from app.core.limiter import limiter
from app.db.models import Guide, Place, Story
from app.db.session import Base, SessionLocal, engine
from scripts.seed import seed

client = TestClient(app, raise_server_exceptions=True)


@pytest.fixture(scope="session", autouse=True)
def setup_test_db():
    # Disable rate limiter during tests
    limiter.enabled = False
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    seed()
    yield
    # Limiter re-enabled
    limiter.enabled = True


# ─── 1. Health & System ───────────────────────────────────────────────────────

def test_health_check():
    resp = client.get("/api/health")
    assert resp.status_code == 200
    data = resp.json()
    assert data["data"]["status"] == "ok"


# ─── 2. Auth Flow ─────────────────────────────────────────────────────────────

def test_auth_full_lifecycle():
    email = "newuser@example.com"
    pwd = "ValidPassword123"

    # 1. Register
    r_reg = client.post(
        "/api/auth/register",
        json={"full_name": "New User", "identifier": email, "password": pwd},
    )
    assert r_reg.status_code == 201
    reg_data = r_reg.json()["data"]
    assert reg_data["user"]["identifier"] == email
    assert reg_data["user"]["has_preferences"] is False
    access_token = reg_data["access_token"]
    refresh_token = reg_data["refresh_token"]

    auth_header = {"Authorization": f"Bearer {access_token}"}

    # 2. Duplicate registration fails (409)
    r_dup = client.post(
        "/api/auth/register",
        json={"full_name": "New User", "identifier": email, "password": pwd},
    )
    assert r_dup.status_code == 409
    assert r_dup.json()["error"]["code"] == "EMAIL_ALREADY_EXISTS"

    # 3. Login with bad password fails (401)
    r_bad = client.post(
        "/api/auth/login",
        json={"identifier": email, "password": "WrongPassword1"},
    )
    assert r_bad.status_code == 401
    assert r_bad.json()["error"]["code"] == "INVALID_CREDENTIALS"

    # 4. Login with correct password succeeds (200)
    r_login = client.post(
        "/api/auth/login",
        json={"identifier": email, "password": pwd},
    )
    assert r_login.status_code == 200
    assert r_login.json()["data"]["user"]["identifier"] == email

    # 5. Protected endpoint without token fails (401)
    r_unauth = client.get("/api/users/me")
    assert r_unauth.status_code == 401
    assert r_unauth.json()["error"]["code"] == "UNAUTHORIZED"

    # 6. Protected endpoint with token succeeds (200)
    r_me = client.get("/api/users/me", headers=auth_header)
    assert r_me.status_code == 200
    assert r_me.json()["data"]["identifier"] == email

    # 7. Refresh token rotation
    r_ref = client.post(
        "/api/auth/refresh",
        json={"refresh_token": refresh_token},
    )
    assert r_ref.status_code == 200
    new_refresh = r_ref.json()["data"]["refresh_token"]

    # 8. Reusing old token fails (401)
    r_replay = client.post(
        "/api/auth/refresh",
        json={"refresh_token": refresh_token},
    )
    assert r_replay.status_code == 401

    # 9. Logout
    r_logout = client.post(
        "/api/auth/logout",
        headers=auth_header,
        json={"refresh_token": new_refresh},
    )
    assert r_logout.status_code == 204


# ─── 3. Personalization & Preferences ─────────────────────────────────────────

def test_preferences_lifecycle():
    email = "preftest@example.com"
    pwd = "ValidPassword123"
    r_reg = client.post(
        "/api/auth/register",
        json={"full_name": "Pref User", "identifier": email, "password": pwd},
    )
    auth_header = {"Authorization": f"Bearer {r_reg.json()['data']['access_token']}"}

    # Save preferences
    pref_payload = {
        "persona": "visitor",
        "purpose": "tourism",
        "stay_length": "few_days",
        "interests": ["historical", "nubian", "food"],
        "travel_styles": ["calm", "cultural"],
        "companions": "solo",
        "needs": ["finding_places"],
        "language": "en",
    }
    r_save = client.put(
        "/api/users/preferences",
        headers=auth_header,
        json=pref_payload,
    )
    assert r_save.status_code == 204

    # Verify has_preferences is now True
    r_me = client.get("/api/users/me", headers=auth_header)
    assert r_me.json()["data"]["has_preferences"] is True

    # Retrieve preferences
    r_get = client.get("/api/users/preferences", headers=auth_header)
    assert r_get.status_code == 200
    assert r_get.json()["data"]["persona"] == "visitor"
    assert "historical" in r_get.json()["data"]["interests"]


# ─── 4. Places & Bookmarks ────────────────────────────────────────────────────

def test_places_and_bookmarks():
    # Public list
    r_places = client.get("/api/places")
    assert r_places.status_code == 200
    places_data = r_places.json()["data"]
    assert len(places_data) >= 4
    assert r_places.json()["meta"]["total"] >= 4

    # Curated
    r_curated = client.get("/api/places/curated")
    assert r_curated.status_code == 200
    assert len(r_curated.json()["data"]) > 0

    # Place details
    r_details = client.get("/api/places/philae")
    assert r_details.status_code == 200
    assert r_details.json()["data"]["id"] == "philae"
    assert "facts" in r_details.json()["data"]

    # Bookmark flow
    email = "bmuser@example.com"
    r_reg = client.post(
        "/api/auth/register",
        json={"full_name": "BM User", "identifier": email, "password": "ValidPassword123"},
    )
    auth_header = {"Authorization": f"Bearer {r_reg.json()['data']['access_token']}"}

    # Add bookmark
    r_bm = client.post(
        "/api/bookmarks",
        headers=auth_header,
        json={"place_id": "philae"},
    )
    assert r_bm.status_code == 201
    assert r_bm.json()["data"]["is_bookmarked"] is True

    # List bookmarks
    r_bms = client.get("/api/bookmarks", headers=auth_header)
    assert r_bms.status_code == 200
    assert len(r_bms.json()["data"]) == 1

    # Remove bookmark
    r_del = client.delete("/api/bookmarks/philae", headers=auth_header)
    assert r_del.status_code == 200
    assert r_del.json()["data"]["is_bookmarked"] is False


# ─── 5. Guides & Booking Requests ─────────────────────────────────────────────

def test_guides_and_requests():
    r_guides = client.get("/api/guides")
    assert r_guides.status_code == 200
    assert len(r_guides.json()["data"]) >= 2

    # Guide details
    r_g = client.get("/api/guides/youssef-el-nuby")
    assert r_g.status_code == 200
    assert r_g.json()["data"]["full_name"] == "Youssef El Nuby"

    # User booking request
    email = "guideuser@example.com"
    r_reg = client.post(
        "/api/auth/register",
        json={"full_name": "Guide User", "identifier": email, "password": "ValidPassword123"},
    )
    auth_header = {"Authorization": f"Bearer {r_reg.json()['data']['access_token']}"}

    tomorrow = (date.today() + timedelta(days=1)).isoformat()
    req_body = {
        "guide_id": "youssef-el-nuby",
        "date": tomorrow,
        "duration": "one_day",
        "start_time": "10:00",
        "group_size": 2,
        "language": "en",
        "interests": ["nubian_culture", "historical_sites"],
        "notes": "Looking forward to exploring Philae and villages.",
    }
    r_req = client.post("/api/guide-requests", headers=auth_header, json=req_body)
    assert r_req.status_code == 201
    assert r_req.json()["data"]["status"] == "pending"

    # List my requests
    r_my_reqs = client.get("/api/guide-requests/mine", headers=auth_header)
    assert r_my_reqs.status_code == 200
    assert len(r_my_reqs.json()["data"]) == 1


# ─── 6. Place Reports ─────────────────────────────────────────────────────────

def test_place_report_submission():
    email = "reportuser@example.com"
    r_reg = client.post(
        "/api/auth/register",
        json={"full_name": "Reporter", "identifier": email, "password": "ValidPassword123"},
    )
    auth_header = {"Authorization": f"Bearer {r_reg.json()['data']['access_token']}"}

    r_rep = client.post(
        "/api/place-reports",
        headers=auth_header,
        data={
            "place_id": "philae",
            "reason": "incorrect_information",
            "details": "Opening hours changed for Ramadan season.",
        },
    )
    assert r_rep.status_code == 201
    assert r_rep.json()["data"]["points_pending"] == 25

    # List my reports
    r_mine = client.get("/api/place-reports/mine", headers=auth_header)
    assert r_mine.status_code == 200
    assert len(r_mine.json()["data"]) == 1


# ─── 7. Culture & Themes ──────────────────────────────────────────────────────

def test_culture_home_and_themes():
    r_home = client.get("/api/culture/home")
    assert r_home.status_code == 200
    data = r_home.json()["data"]
    assert "themes" in data
    assert len(data["themes"]) == 4


# ─── 8. Community Social Feed & Interactions ──────────────────────────────────

def test_community_social_feed():
    email = "postuser@example.com"
    r_reg = client.post(
        "/api/auth/register",
        json={"full_name": "Post User", "identifier": email, "password": "ValidPassword123"},
    )
    auth_header = {"Authorization": f"Bearer {r_reg.json()['data']['access_token']}"}

    # Dummy image bytes (JPEG magic number)
    fake_jpeg = b"\xff\xd8\xff\xe0\x00\x10JFIF" + b"\x00" * 50

    # 1. Create Post
    r_post = client.post(
        "/api/community/posts",
        headers=auth_header,
        data={
            "caption": "Sunset over Philae island!",
            "category": "local_experience",
            "location": "Philae Temple",
        },
        files=[("images", ("sunset.jpg", io.BytesIO(fake_jpeg), "image/jpeg"))],
    )
    assert r_post.status_code == 201
    post_id = r_post.json()["data"]["id"]

    # 2. Like Post
    r_like = client.post(f"/api/community/posts/{post_id}/like", headers=auth_header)
    assert r_like.status_code == 200
    assert r_like.json()["data"]["like_count"] == 1
    assert r_like.json()["data"]["is_liked"] is True

    # 3. Add Comment
    r_cmt = client.post(
        f"/api/community/posts/{post_id}/comments",
        headers=auth_header,
        json={"text": "Incredible view!"},
    )
    assert r_cmt.status_code == 201
    cmt_id = r_cmt.json()["data"]["id"]

    # 4. List Comments
    r_cmts = client.get(f"/api/community/posts/{post_id}/comments")
    assert r_cmts.status_code == 200
    assert len(r_cmts.json()["data"]) == 1

    # 5. Delete Comment
    r_del_cmt = client.delete(f"/api/community/comments/{cmt_id}", headers=auth_header)
    assert r_del_cmt.status_code == 204

    # 6. Delete Post
    r_del_post = client.delete(f"/api/community/posts/{post_id}", headers=auth_header)
    assert r_del_post.status_code == 204


# ─── 9. Profile & Settings ────────────────────────────────────────────────────

def test_profile_and_settings():
    email = "profiletest@example.com"
    r_reg = client.post(
        "/api/auth/register",
        json={"full_name": "Profile Test", "identifier": email, "password": "ValidPassword123"},
    )
    auth_header = {"Authorization": f"Bearer {r_reg.json()['data']['access_token']}"}

    # Get Profile
    r_prof = client.get("/api/users/me/profile", headers=auth_header)
    assert r_prof.status_code == 200
    pdata = r_prof.json()["data"]
    assert "stats" in pdata
    assert "contributions" in pdata

    # Update Settings
    r_set = client.patch(
        "/api/users/settings",
        headers=auth_header,
        json={"language": "ar", "notifications_enabled": False},
    )
    assert r_set.status_code == 200
    assert r_set.json()["data"]["language"] == "ar"
    assert r_set.json()["data"]["notifications_enabled"] is False

    # Deletion request
    r_del = client.post("/api/users/me/deletion-request", headers=auth_header)
    assert r_del.status_code == 202
    assert r_del.json()["data"]["status"] == "requested"
