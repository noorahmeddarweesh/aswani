import hmac
from datetime import timedelta

from sqlalchemy import select, update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.errors import AppError
from app.core.security import (
    as_utc, burn_time, create_access_token, create_refresh_token, decode_token,
    generate_reset_code, hash_password, hash_reset_code, now, sha256, verify_password,
)
from app.core.validators import normalize_email
from app.db.models import PasswordResetCode, RefreshToken, User

DEMO_EMAIL = "laila@example.com"
DEMO_CODE = "1234"
MAX_CODE_ATTEMPTS = 5


def user_to_dict(user: User) -> dict:
    return {
        "id": user.id,
        "full_name": user.full_name,
        "identifier": user.identifier,
        "has_preferences": user.preferences is not None,
    }


# ---------- أخطاء بالأكواد المتفق عليها في العقد ----------
def _invalid_credentials() -> AppError:
    return AppError(401, "INVALID_CREDENTIALS", "Wrong identifier or password")


def _unauthorized() -> AppError:
    return AppError(401, "UNAUTHORIZED", "Invalid or expired refresh token")


def _user_not_found() -> AppError:
    return AppError(404, "USER_NOT_FOUND", "Account not found", {"identifier": "USER_NOT_FOUND"})


def _invalid_code() -> AppError:
    return AppError(422, "INVALID_CODE", "Wrong or expired code", {"code": "INVALID_CODE"})


def _email_exists() -> AppError:
    return AppError(409, "EMAIL_ALREADY_EXISTS", "Identifier already used", {"identifier": "EMAIL_ALREADY_EXISTS"})


# ---------- مساعدات ----------
def _find_user(db: Session, identifier: str) -> User | None:
    return db.scalar(select(User).where(User.identifier == normalize_email(identifier)))


def _issue_tokens(db: Session, user: User) -> tuple[str, str]:
    access = create_access_token(user.id)
    refresh = create_refresh_token(user.id)
    db.add(RefreshToken(
        user_id=user.id,
        token_hash=sha256(refresh),
        expires_at=now() + timedelta(days=settings.refresh_token_days),
    ))
    return access, refresh


def _revoke_all(db: Session, user_id: str) -> None:
    db.execute(
        update(RefreshToken)
        .where(RefreshToken.user_id == user_id, RefreshToken.revoked_at.is_(None))
        .values(revoked_at=now())
    )


def _auth_response(db: Session, user: User) -> dict:
    access, refresh = _issue_tokens(db, user)
    db.commit()
    return {"user": user_to_dict(user), "access_token": access, "refresh_token": refresh}


# ---------- العمليات ----------
def register(db: Session, full_name: str, identifier: str, password: str) -> dict:
    if _find_user(db, identifier):
        raise _email_exists()
    user = User(full_name=full_name, identifier=identifier, password_hash=hash_password(password))
    db.add(user)
    try:
        db.flush()
    except IntegrityError:  # اتنين سجّلوا بنفس الإيميل في نفس الثانية
        db.rollback()
        raise _email_exists()
    return _auth_response(db, user)


def login(db: Session, identifier: str, password: str) -> dict:
    user = _find_user(db, identifier)
    if user is None:
        burn_time()  # نفس الزمن سواء الحساب موجود أو لأ
        raise _invalid_credentials()
    if not verify_password(password, user.password_hash):
        raise _invalid_credentials()
    return _auth_response(db, user)


def refresh(db: Session, refresh_token: str) -> dict:
    if decode_token(refresh_token, "refresh") is None:
        raise _unauthorized()
    row = db.scalar(select(RefreshToken).where(RefreshToken.token_hash == sha256(refresh_token)))
    if row is None:
        raise _unauthorized()
    if row.revoked_at is not None:
        # توكن مستخدم قبل كده = ممكن اتسرق، نبطّل كل توكنز اليوزر احتياطياً
        _revoke_all(db, row.user_id)
        db.commit()
        raise _unauthorized()
    if as_utc(row.expires_at) < now():
        raise _unauthorized()

    user = db.get(User, row.user_id)
    if user is None:
        raise _unauthorized()
    row.revoked_at = now()  # rotation: القديم يتبطل ويطلع جديد
    access, new_refresh = _issue_tokens(db, user)
    db.commit()
    return {"access_token": access, "refresh_token": new_refresh}


def logout(db: Session, user: User, refresh_token: str) -> None:
    row = db.scalar(select(RefreshToken).where(
        RefreshToken.token_hash == sha256(refresh_token), RefreshToken.user_id == user.id
    ))
    if row is not None and row.revoked_at is None:
        row.revoked_at = now()
        db.commit()


def forgot_password(db: Session, identifier: str) -> tuple[str, str, bool]:
    """يرجّع (الإيميل، الكود، هل نبعت إيميل؟)."""
    user = _find_user(db, identifier)
    if user is None:
        raise _user_not_found()

    is_demo = settings.demo_mode and user.identifier == DEMO_EMAIL
    code = DEMO_CODE if is_demo else generate_reset_code()

    # أي كود قديم غير مستخدم يتبطل
    db.execute(update(PasswordResetCode).where(
        PasswordResetCode.user_id == user.id, PasswordResetCode.used_at.is_(None)
    ).values(used_at=now()))
    db.add(PasswordResetCode(
        user_id=user.id,
        code_hash=hash_reset_code(user.id, code),
        expires_at=now() + timedelta(minutes=settings.reset_code_minutes),
    ))
    db.commit()
    return user.identifier, code, not is_demo


def reset_password(db: Session, identifier: str, code: str, new_password: str) -> None:
    user = _find_user(db, identifier)
    if user is None:
        raise _user_not_found()

    row = db.scalar(
        select(PasswordResetCode)
        .where(PasswordResetCode.user_id == user.id, PasswordResetCode.used_at.is_(None))
        .order_by(PasswordResetCode.created_at.desc())
        .limit(1)
    )
    if row is None or as_utc(row.expires_at) < now() or row.attempts >= MAX_CODE_ATTEMPTS:
        raise _invalid_code()

    row.attempts += 1
    if not hmac.compare_digest(row.code_hash, hash_reset_code(user.id, code)):
        db.commit()  # لازم نحفظ عداد المحاولات حتى لو الكود غلط
        raise _invalid_code()

    row.used_at = now()
    user.password_hash = hash_password(new_password)
    _revoke_all(db, user.id)  # تغيير الباسورد يخرّج كل الأجهزة
    db.commit()