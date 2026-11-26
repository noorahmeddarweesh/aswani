"""
app/core/security.py
────────────────────
All cryptographic operations for Aswani:

  • Argon2 password hashing  (argon2-cffi)
  • JWT access token creation & decoding  (PyJWT)
  • Refresh token generation & SHA-256 hashing
  • HMAC-SHA256 password-reset code generation & verification

Nothing here touches the database or HTTP layer.
"""
from __future__ import annotations

import hashlib
import hmac
import os
import secrets
import uuid
from datetime import datetime, timedelta, timezone

import jwt
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError, VerificationError, InvalidHashError

from app.core.config import settings

# ─── Argon2 hasher (singleton, thread-safe) ──────────────────────────────────
_ph = PasswordHasher(
    time_cost=2,        # number of iterations
    memory_cost=65536,  # 64 MiB
    parallelism=2,
    hash_len=32,
    salt_len=16,
)


# ─── Time helpers ─────────────────────────────────────────────────────────────

def utcnow() -> datetime:
    """Return timezone-aware current UTC time."""
    return datetime.now(timezone.utc)


def as_utc(dt: datetime) -> datetime:
    """Ensure datetime has UTC timezone for cross-database compatibility."""
    return dt if dt.tzinfo else dt.replace(tzinfo=timezone.utc)


# ─── Password hashing ─────────────────────────────────────────────────────────

def hash_password(plain: str) -> str:
    """Return a new Argon2id hash of *plain*."""
    return _ph.hash(plain)


def verify_password(plain: str, hashed: str) -> bool:
    """
    Return True when *plain* matches *hashed*.

    Intentionally catches every Argon2 exception and returns False, so
    callers never need to handle library-specific errors.
    """
    try:
        return _ph.verify(hashed, plain)
    except (VerifyMismatchError, VerificationError, InvalidHashError):
        return False


def password_needs_rehash(hashed: str) -> bool:
    """True when the stored hash uses outdated parameters and should be rehashed."""
    return _ph.check_needs_rehash(hashed)


def burn_time() -> None:
    """
    Hash a dummy string with Argon2 so that "user not found" and
    "wrong password" code paths take the same wall-clock time,
    eliminating user-enumeration via timing analysis.
    """
    verify_password("dummy", hash_password("x"))


# ─── JWT access tokens ────────────────────────────────────────────────────────

def create_access_token(user_id: str, identifier: str) -> str:
    """
    Create a signed JWT containing:
      sub   – user UUID (as string)
      email – the user's login identifier
      iat   – issued-at (UTC)
      exp   – expiry (UTC, ACCESS_TOKEN_EXPIRE_MINUTES from now)
      jti   – unique token ID (prevents replay within its lifetime)
    """
    now = datetime.now(timezone.utc)
    payload = {
        "sub": user_id,
        "identifier": identifier,
        "iat": now,
        "exp": now + timedelta(minutes=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES),
        "jti": str(uuid.uuid4()),
    }
    return jwt.encode(payload, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)


def decode_access_token(token: str) -> dict:
    """
    Decode and validate a JWT.

    Raises:
        jwt.ExpiredSignatureError   – token has expired
        jwt.InvalidTokenError       – any other JWT problem
    """
    return jwt.decode(
        token,
        settings.JWT_SECRET_KEY,
        algorithms=[settings.JWT_ALGORITHM],
        options={"require": ["sub", "exp", "iat"]},
    )


# ─── Refresh tokens ───────────────────────────────────────────────────────────

def generate_refresh_token() -> str:
    """
    Return a cryptographically secure 64-byte URL-safe random token (88 chars).
    The raw token is sent to the client; only its SHA-256 hash is stored.
    """
    return secrets.token_urlsafe(64)


def hash_token(raw: str) -> str:
    """
    Return the SHA-256 hex digest of *raw*.
    Used for storing refresh tokens — we never store the raw value.
    """
    return hashlib.sha256(raw.encode()).hexdigest()


# ─── Password-reset codes ─────────────────────────────────────────────────────

def generate_reset_code() -> tuple[str, str]:
    """
    Return ``(plain_code, hashed_code)`` where:
      • plain_code  – 4-digit string sent to the user via email/SMS
      • hashed_code – HMAC-SHA256 hex stored in the database

    Using HMAC (keyed by RESET_CODE_SECRET) instead of a plain hash
    prevents precomputed rainbow-table attacks against the 4-digit space.
    """
    plain = f"{secrets.randbelow(10_000):04d}"
    hashed = _hmac_reset_code(plain)
    return plain, hashed


def verify_reset_code(plain: str, stored_hashed: str) -> bool:
    """
    Constant-time comparison of the user-supplied *plain* code
    against the HMAC *stored_hashed*.
    """
    expected = _hmac_reset_code(plain)
    return hmac.compare_digest(expected, stored_hashed)


def _hmac_reset_code(plain: str) -> str:
    return hmac.new(
        settings.RESET_CODE_SECRET.encode(),
        plain.encode(),
        hashlib.sha256,
    ).hexdigest()
