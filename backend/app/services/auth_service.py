"""
app/services/auth_service.py
────────────────────────────
Business logic for user registration, authentication, token lifecycle,
and password reset workflows.
"""
from __future__ import annotations

import logging
from datetime import timedelta
from typing import Optional

from sqlalchemy import select, update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.errors import AppError
from app.core.security import (
    as_utc,
    burn_time,
    create_access_token,
    generate_refresh_token,
    generate_reset_code,
    hash_password,
    hash_token,
    utcnow,
    verify_password,
    verify_reset_code,
)
from app.core.validators import normalize_email
from app.db.models import PasswordResetCode, RefreshToken, User

logger = logging.getLogger(__name__)

DEMO_CODE = "1234"


def user_to_dict(user: User) -> dict:
    """Serialize a User entity to the JSON shape expected by mobile."""
    return {
        "id": user.id,
        "full_name": user.full_name,
        "identifier": user.identifier,
        "has_preferences": user.preferences is not None,
        "avatar_url": user.avatar,
    }


def _auth_response(db: Session, user: User) -> dict:
    """Issue a fresh access/refresh token pair and record the session."""
    raw_refresh = generate_refresh_token()
    refresh_hash = hash_token(raw_refresh)
    expires_at = utcnow() + timedelta(days=settings.JWT_REFRESH_TOKEN_EXPIRE_DAYS)

    db.add(
        RefreshToken(
            user_id=user.id,
            token_hash=refresh_hash,
            expires_at=expires_at,
        )
    )
    db.commit()

    access_token = create_access_token(user.id, user.identifier)
    return {
        "user": user_to_dict(user),
        "access_token": access_token,
        "refresh_token": raw_refresh,
    }


def _revoke_all_sessions(db: Session, user_id: str) -> None:
    """Revoke all active refresh tokens for a user (used after security incidents or password changes)."""
    db.execute(
        update(RefreshToken)
        .where(RefreshToken.user_id == user_id, RefreshToken.revoked_at.is_(None))
        .values(revoked_at=utcnow())
    )


def register(db: Session, full_name: str, identifier: str, password: str) -> dict:
    norm_identifier = normalize_email(identifier)
    existing = db.scalar(select(User).where(User.identifier == norm_identifier))
    if existing:
        raise AppError(
            409,
            "EMAIL_ALREADY_EXISTS",
            "An account with this email already exists.",
            {"identifier": "EMAIL_ALREADY_EXISTS"},
        )

    user = User(
        full_name=full_name,
        identifier=norm_identifier,
        password_hash=hash_password(password),
    )
    db.add(user)
    try:
        db.flush()
    except IntegrityError:
        db.rollback()
        raise AppError(
            409,
            "EMAIL_ALREADY_EXISTS",
            "An account with this email already exists.",
            {"identifier": "EMAIL_ALREADY_EXISTS"},
        )

    return _auth_response(db, user)


def login(db: Session, identifier: str, password: str) -> dict:
    norm_identifier = normalize_email(identifier)
    user = db.scalar(select(User).where(User.identifier == norm_identifier))
    if not user:
        burn_time()
        raise AppError(401, "INVALID_CREDENTIALS", "Email or password is incorrect.")

    if not verify_password(password, user.password_hash):
        raise AppError(401, "INVALID_CREDENTIALS", "Email or password is incorrect.")

    return _auth_response(db, user)


def refresh(db: Session, raw_refresh_token: str) -> dict:
    t_hash = hash_token(raw_refresh_token)
    token_row = db.scalar(select(RefreshToken).where(RefreshToken.token_hash == t_hash))

    if not token_row:
        raise AppError(401, "UNAUTHORIZED", "Invalid or missing refresh token.")

    # Replay attack detection: if token was already revoked, terminate all sessions
    if token_row.revoked_at is not None:
        logger.warning(
            "Replay attack detected on refresh token %s for user %s. Revoking all sessions.",
            t_hash[:8],
            token_row.user_id,
        )
        _revoke_all_sessions(db, token_row.user_id)
        db.commit()
        raise AppError(401, "UNAUTHORIZED", "Revoked refresh token re-used.")

    # Expiry check
    if as_utc(token_row.expires_at) < utcnow():
        raise AppError(401, "UNAUTHORIZED", "Refresh token has expired.")

    user = db.get(User, token_row.user_id)
    if not user:
        raise AppError(401, "UNAUTHORIZED", "User not found.")

    # Rotate token: invalidate the used one and issue a fresh pair
    token_row.revoked_at = utcnow()
    new_raw_refresh = generate_refresh_token()
    db.add(
        RefreshToken(
            user_id=user.id,
            token_hash=hash_token(new_raw_refresh),
            expires_at=utcnow() + timedelta(days=settings.JWT_REFRESH_TOKEN_EXPIRE_DAYS),
        )
    )
    db.commit()

    new_access_token = create_access_token(user.id, user.identifier)
    return {
        "access_token": new_access_token,
        "refresh_token": new_raw_refresh,
    }


def logout(db: Session, user_id: str, raw_refresh_token: str) -> None:
    t_hash = hash_token(raw_refresh_token)
    token_row = db.scalar(
        select(RefreshToken).where(
            RefreshToken.token_hash == t_hash, RefreshToken.user_id == user_id
        )
    )
    if token_row and token_row.revoked_at is None:
        token_row.revoked_at = utcnow()
        db.commit()


def forgot_password(db: Session, identifier: str) -> tuple[str, str, bool]:
    norm_identifier = normalize_email(identifier)
    user = db.scalar(select(User).where(User.identifier == norm_identifier))
    if not user:
        raise AppError(
            404,
            "USER_NOT_FOUND",
            "Account not found",
            {"identifier": "USER_NOT_FOUND"},
        )

    # In staging / demo mode for Laila Hassan
    is_demo = (
        not settings.is_production
        and user.identifier.lower() == settings.SEED_DEMO_EMAIL.lower()
    )
    if is_demo:
        code = DEMO_CODE
        plain, hashed = DEMO_CODE, DEMO_CODE
    else:
        plain, hashed = generate_reset_code()
        code = plain

    # Invalidate previous unused codes
    db.execute(
        update(PasswordResetCode)
        .where(
            PasswordResetCode.user_id == user.id,
            PasswordResetCode.used_at.is_(None),
        )
        .values(used_at=utcnow())
    )

    db.add(
        PasswordResetCode(
            user_id=user.id,
            code_hash=hashed,
            expires_at=utcnow() + timedelta(minutes=settings.RESET_CODE_EXPIRE_MINUTES),
        )
    )
    db.commit()

    return user.identifier, code, not is_demo


def reset_password(
    db: Session, identifier: str, code: str, new_password: str
) -> None:
    norm_identifier = normalize_email(identifier)
    user = db.scalar(select(User).where(User.identifier == norm_identifier))
    if not user:
        raise AppError(
            404,
            "USER_NOT_FOUND",
            "Account not found",
            {"identifier": "USER_NOT_FOUND"},
        )

    code_row = db.scalar(
        select(PasswordResetCode)
        .where(
            PasswordResetCode.user_id == user.id,
            PasswordResetCode.used_at.is_(None),
        )
        .order_by(PasswordResetCode.created_at.desc())
        .limit(1)
    )

    if (
        not code_row
        or as_utc(code_row.expires_at) < utcnow()
        or code_row.attempts >= settings.RESET_CODE_MAX_ATTEMPTS
    ):
        raise AppError(422, "INVALID_CODE", "Invalid or expired code", {"code": "INVALID_CODE"})

    code_row.attempts += 1

    # Check demo code or HMAC code
    is_demo = (
        not settings.is_production
        and user.identifier.lower() == settings.SEED_DEMO_EMAIL.lower()
    )
    valid = (code == DEMO_CODE) if is_demo else verify_reset_code(code, code_row.code_hash)

    if not valid:
        db.commit()  # commit incremented attempt count
        raise AppError(422, "INVALID_CODE", "Invalid or expired code", {"code": "INVALID_CODE"})

    code_row.used_at = utcnow()
    user.password_hash = hash_password(new_password)
    _revoke_all_sessions(db, user.id)
    db.commit()


def change_password(
    db: Session, user_id: str, current_password: str, new_password: str
) -> None:
    user = db.get(User, user_id)
    if not user:
        raise AppError(401, "UNAUTHORIZED", "User not found.")

    if not verify_password(current_password, user.password_hash):
        raise AppError(
            422,
            "INVALID_CURRENT_PASSWORD",
            "Current password does not match.",
            {"current_password": "INVALID_CURRENT_PASSWORD"},
        )

    user.password_hash = hash_password(new_password)
    _revoke_all_sessions(db, user.id)
    db.commit()
