"""
tests/test_phase1.py
────────────────────
Phase 1 smoke tests — verifies every foundational module is correct
WITHOUT any database or external service calls.

Run from backend/ with:
    pytest tests/test_phase1.py -v
"""
from __future__ import annotations

import os
import time

# Set a test DATABASE_URL before importing any app module
os.environ.setdefault("DATABASE_URL", "sqlite:///./test_aswani.db")
os.environ.setdefault("JWT_SECRET_KEY", "test-secret-key-must-be-at-least-32-chars-long")
os.environ.setdefault("APP_SECRET_KEY", "test-app-secret-key-at-least-32-ch")
os.environ.setdefault("RESET_CODE_SECRET", "test-reset-hmac-secret")

import pytest

# ─── Security ─────────────────────────────────────────────────────────────────

class TestPasswordHashing:
    def test_hash_is_not_plaintext(self):
        from app.core.security import hash_password
        h = hash_password("SomePassword1")
        assert h != "SomePassword1"
        assert h.startswith("$argon2")

    def test_correct_password_verifies(self):
        from app.core.security import hash_password, verify_password
        h = hash_password("SomePassword1")
        assert verify_password("SomePassword1", h) is True

    def test_wrong_password_fails(self):
        from app.core.security import hash_password, verify_password
        h = hash_password("SomePassword1")
        assert verify_password("WrongPassword9", h) is False

    def test_different_hashes_for_same_input(self):
        """Argon2 must use a random salt each time."""
        from app.core.security import hash_password
        h1 = hash_password("SamePassword1")
        h2 = hash_password("SamePassword1")
        assert h1 != h2


class TestJWT:
    def test_encode_decode_roundtrip(self):
        from app.core.security import create_access_token, decode_access_token
        token = create_access_token("user-uuid-123", "test@example.com")
        payload = decode_access_token(token)
        assert payload["sub"] == "user-uuid-123"
        assert payload["identifier"] == "test@example.com"

    def test_expired_token_raises(self):
        import jwt
        from datetime import datetime, timezone, timedelta
        from app.core.config import settings

        payload = {
            "sub": "u1",
            "identifier": "x@x.com",
            "iat": datetime.now(timezone.utc) - timedelta(hours=2),
            "exp": datetime.now(timezone.utc) - timedelta(hours=1),
            "jti": "test-jti",
        }
        expired = jwt.encode(payload, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)
        with pytest.raises(jwt.ExpiredSignatureError):
            from app.core.security import decode_access_token
            decode_access_token(expired)

    def test_tampered_token_raises(self):
        import jwt
        from app.core.security import create_access_token, decode_access_token
        token = create_access_token("u1", "a@b.com")
        tampered = token[:-4] + "XXXX"
        with pytest.raises(jwt.InvalidTokenError):
            decode_access_token(tampered)


class TestRefreshTokens:
    def test_token_is_url_safe_string(self):
        from app.core.security import generate_refresh_token
        t = generate_refresh_token()
        assert isinstance(t, str)
        assert len(t) > 50

    def test_hash_is_deterministic(self):
        from app.core.security import hash_token
        assert hash_token("abc") == hash_token("abc")

    def test_different_inputs_different_hashes(self):
        from app.core.security import hash_token
        assert hash_token("abc") != hash_token("xyz")

    def test_hash_has_correct_length(self):
        """SHA-256 hex digest is always 64 characters."""
        from app.core.security import hash_token
        assert len(hash_token("anything")) == 64


class TestResetCodes:
    def test_code_is_4_digits(self):
        from app.core.security import generate_reset_code
        plain, _ = generate_reset_code()
        assert plain.isdigit()
        assert len(plain) == 4

    def test_correct_code_verifies(self):
        from app.core.security import generate_reset_code, verify_reset_code
        plain, hashed = generate_reset_code()
        assert verify_reset_code(plain, hashed) is True

    def test_wrong_code_fails(self):
        from app.core.security import generate_reset_code, verify_reset_code
        _, hashed = generate_reset_code()
        assert verify_reset_code("0000", hashed) is False


# ─── Validators ───────────────────────────────────────────────────────────────

class TestEmailValidator:
    def test_valid_email_normalized(self):
        from app.core.validators import normalize_email
        assert normalize_email("  Test@Example.COM  ") == "test@example.com"

    @pytest.mark.parametrize("bad", ["not-an-email", "@domain.com", "user@", "", "  "])
    def test_invalid_email_raises(self, bad):
        from app.core.validators import normalize_email
        with pytest.raises(ValueError, match="INVALID_EMAIL"):
            normalize_email(bad)


class TestPasswordValidator:
    def test_valid_password_passes(self):
        from app.core.validators import validate_password
        assert validate_password("ValidPass1") == "ValidPass1"

    @pytest.mark.parametrize("bad", [
        "short1A",          # too short (7 chars)
        "alllowercase1",    # no uppercase
        "ALLUPPERCASE1",    # no lowercase
        "NoDigitsHere",     # no digit
        "a" * 129 + "A1",   # too long
    ])
    def test_weak_password_raises(self, bad):
        from app.core.validators import validate_password
        with pytest.raises(ValueError, match="WEAK_PASSWORD"):
            validate_password(bad)


class TestPhoneValidator:
    @pytest.mark.parametrize("raw,expected", [
        ("01012345678",   "+201012345678"),
        ("+201012345678", "+201012345678"),
        ("00201012345678","+201012345678"),
        ("1012345678",    "+201012345678"),
    ])
    def test_valid_phones_normalized(self, raw, expected):
        from app.core.validators import normalize_phone
        assert normalize_phone(raw) == expected

    @pytest.mark.parametrize("bad", ["01312345678", "123456", "+44791234567"])
    def test_invalid_phones_raise(self, bad):
        from app.core.validators import normalize_phone
        with pytest.raises(ValueError, match="INVALID_PHONE"):
            normalize_phone(bad)


# ─── Response builders ────────────────────────────────────────────────────────

class TestResponses:
    def test_ok_wraps_data(self):
        from app.core.responses import ok
        result = ok({"id": "1", "name": "Philae"})
        assert result == {"data": {"id": "1", "name": "Philae"}}

    def test_paginated_meta(self):
        from app.core.responses import paginated
        result = paginated(["a", "b"], page=2, limit=20, total=45)
        assert result["meta"]["page"] == 2
        assert result["meta"]["total_pages"] == 3
        assert result["meta"]["total"] == 45
        assert result["data"] == ["a", "b"]

    def test_paginated_single_page(self):
        from app.core.responses import paginated
        result = paginated([], page=1, limit=20, total=0)
        assert result["meta"]["total_pages"] == 1   # never 0

    def test_paginated_exact_fit(self):
        from app.core.responses import paginated
        result = paginated([], page=1, limit=20, total=20)
        assert result["meta"]["total_pages"] == 1


# ─── Error class ─────────────────────────────────────────────────────────────

class TestAppError:
    def test_attributes_set_correctly(self):
        from app.core.errors import AppError
        err = AppError(404, "PLACE_NOT_FOUND", "No place with id=abc")
        assert err.status_code == 404
        assert err.code == "PLACE_NOT_FOUND"
        assert err.message == "No place with id=abc"
        assert err.details == {}

    def test_field_errors_stored(self):
        from app.core.errors import AppError
        err = AppError(422, "VALIDATION_ERROR", details={"email": "INVALID_EMAIL"})
        assert err.details == {"email": "INVALID_EMAIL"}

    def test_is_exception(self):
        from app.core.errors import AppError
        assert issubclass(AppError, Exception)


# ─── FastAPI app health ───────────────────────────────────────────────────────

class TestHealthEndpoint:
    def test_health_returns_ok(self):
        from fastapi.testclient import TestClient
        from main import app
        client = TestClient(app, raise_server_exceptions=True)
        resp = client.get("/api/health")
        assert resp.status_code == 200
        body = resp.json()
        assert body["data"]["status"] == "ok"

    def test_error_handler_returns_contract_shape(self):
        """404 on an unknown route must return the contract error envelope."""
        from fastapi.testclient import TestClient
        from main import app
        client = TestClient(app, raise_server_exceptions=False)
        resp = client.get("/api/nonexistent-route")
        assert resp.status_code == 404
        body = resp.json()
        assert "error" in body
        assert "code" in body["error"]
        assert "message" in body["error"]
