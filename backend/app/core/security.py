import hashlib
import hmac
import secrets
import uuid
from datetime import datetime, timedelta, timezone

import jwt
from argon2 import PasswordHasher
from argon2.exceptions import InvalidHashError, VerifyMismatchError

from app.core.config import settings

_hasher = PasswordHasher()
_DUMMY_HASH = _hasher.hash("dummy-password-1")


def now() -> datetime:
    return datetime.now(timezone.utc)


def as_utc(dt: datetime) -> datetime:
    """بعض القواعد بترجع تاريخ من غير timezone، بنوحّده."""
    return dt if dt.tzinfo else dt.replace(tzinfo=timezone.utc)


# ---------- الباسورد ----------
def hash_password(password: str) -> str:
    return _hasher.hash(password)


def verify_password(password: str, password_hash: str) -> bool:
    try:
        return _hasher.verify(password_hash, password)
    except (VerifyMismatchError, InvalidHashError):
        return False


def burn_time() -> None:
    """لما اليوزر مش موجود، بنعمل hash وهمي عشان زمن الرد يبقى نفسه."""
    verify_password("x", _DUMMY_HASH)


# ---------- JWT ----------
def _encode(user_id: str, token_type: str, expires_at: datetime) -> str:
    payload = {
        "sub": user_id,
        "type": token_type,  # access أو refresh
        "iat": now(),
        "exp": expires_at,
        "jti": uuid.uuid4().hex,
    }
    return jwt.encode(payload, settings.jwt_secret, algorithm="HS256")


def create_access_token(user_id: str) -> str:
    return _encode(user_id, "access", now() + timedelta(minutes=settings.access_token_minutes))


def create_refresh_token(user_id: str) -> str:
    return _encode(user_id, "refresh", now() + timedelta(days=settings.refresh_token_days))


def decode_token(token: str, expected_type: str) -> dict | None:
    """يرجّع محتوى التوكن لو سليم ولسه منتهيش ونوعه صح، وإلا None."""
    try:
        payload = jwt.decode(token, settings.jwt_secret, algorithms=["HS256"])
    except jwt.PyJWTError:
        return None
    if payload.get("type") != expected_type:
        return None
    return payload


# ---------- هاش للتخزين ----------
def sha256(value: str) -> str:
    return hashlib.sha256(value.encode()).hexdigest()


# ---------- كود الـ reset ----------
def generate_reset_code() -> str:
    return f"{secrets.randbelow(10000):04d}"  # 4 أرقام


def hash_reset_code(user_id: str, code: str) -> str:
    return hmac.new(settings.jwt_secret.encode(), f"{user_id}:{code}".encode(), hashlib.sha256).hexdigest()