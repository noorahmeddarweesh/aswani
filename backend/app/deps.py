from typing import Annotated

from fastapi import Depends, Query
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.core.errors import AppError
from app.core.security import decode_token
from app.db.models import User
from app.db.session import get_db

bearer_scheme = HTTPBearer(auto_error=False)
DbSession = Annotated[Session, Depends(get_db)]
Creds = Annotated[HTTPAuthorizationCredentials | None, Depends(bearer_scheme)]


def _unauthorized() -> AppError:
    return AppError(401, "UNAUTHORIZED", "Missing, expired or invalid token")


def _load_user(creds: HTTPAuthorizationCredentials, db: Session) -> User:
    payload = decode_token(creds.credentials, "access")
    if payload is None:
        raise _unauthorized()
    user = db.get(User, payload["sub"])
    if user is None:
        raise _unauthorized()
    return user


def get_current_user(creds: Creds, db: DbSession) -> User:
    """للـ endpoints اللي محتاجة تسجيل دخول."""
    if creds is None:
        raise _unauthorized()
    return _load_user(creds, db)


def optional_user(creds: Creds, db: DbSession) -> User | None:
    """للـ endpoints اللي بتشتغل بالتوكن ومن غيره."""
    if creds is None:
        return None
    return _load_user(creds, db)


CurrentUser = Annotated[User, Depends(get_current_user)]
OptionalUser = Annotated[User | None, Depends(optional_user)]


class Pagination:
    """page من 1، limit الافتراضي 20 وأقصى حد 50."""

    def __init__(self, page: int = Query(1, ge=1), limit: int = Query(20, ge=1, le=50)):
        self.page = page
        self.limit = limit
        self.offset = (page - 1) * limit