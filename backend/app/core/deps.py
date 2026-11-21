"""
app/core/deps.py
────────────────
FastAPI dependency functions shared by all routers.

  get_db              – yields a SQLAlchemy Session per request
  get_current_user_id – decodes the Bearer JWT and returns the user UUID string
  optional_user_id    – same but returns None when no token is supplied
  Pagination          – typed query-param bundle (page + limit)
"""
from typing import Generator, Optional
import jwt
from fastapi import Depends, Query
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.errors import AppError
from app.core.security import decode_access_token
from app.core.validators import clamp_page
from app.db.session import SessionLocal

# ─── Database ─────────────────────────────────────────────────────────────────

def get_db() -> Generator[Session, None, None]:
    """Yield a database session for the duration of one request."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# ─── Authentication ───────────────────────────────────────────────────────────

_bearer = HTTPBearer(auto_error=False)


def _extract_user_id(credentials: Optional[HTTPAuthorizationCredentials]) -> str:
    """Decode the JWT and return the user UUID, or raise 401."""
    if credentials is None or credentials.scheme.lower() != "bearer":
        raise AppError(401, "UNAUTHORIZED", "Missing or malformed Authorization header.")
    try:
        payload = decode_access_token(credentials.credentials)
    except jwt.ExpiredSignatureError:
        raise AppError(401, "UNAUTHORIZED", "Access token has expired.")
    except jwt.InvalidTokenError as exc:
        raise AppError(401, "UNAUTHORIZED", f"Invalid access token: {exc}")

    user_id: Optional[str] = payload.get("sub")
    if not user_id:
        raise AppError(401, "UNAUTHORIZED", "Token payload is missing 'sub'.")
    return user_id


def get_current_user_id(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(_bearer),
) -> str:
    """Return the authenticated user's UUID string. Raises 401 if invalid."""
    return _extract_user_id(credentials)


def optional_user_id(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(_bearer),
) -> Optional[str]:
    """Return the user UUID if a valid token is present, otherwise None."""
    if credentials is None:
        return None
    try:
        return _extract_user_id(credentials)
    except AppError:
        return None


# ─── Pagination ───────────────────────────────────────────────────────────────

class Pagination:
    """
    Typed pagination query parameters.
    Inject with ``pg: Pagination = Depends()`` in route signatures.
    """

    def __init__(
        self,
        page: int = Query(default=1, ge=1, description="1-based page number"),
        limit: int = Query(default=20, ge=1, le=100, description="Items per page (max 100)"),
    ) -> None:
        self.page, self.limit = clamp_page(page, limit)

    @property
    def offset(self) -> int:
        return (self.page - 1) * self.limit
