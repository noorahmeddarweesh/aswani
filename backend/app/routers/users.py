"""
app/routers/users.py
────────────────────
User profile, preferences, settings, avatar upload, and account deletion endpoints.
"""
from typing import Optional
from fastapi import APIRouter, Depends, File, Response, UploadFile
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.core.deps import get_current_user_id, get_db
from app.core.errors import AppError
from app.core.responses import ok
from app.db.models import DeletionRequest, User
from app.schemas.preferences import PreferencesIn
from app.services import auth_service, preferences_service, storage_service

router = APIRouter(prefix="/users", tags=["Users"])


class ProfileUpdateIn(BaseModel):
    full_name: Optional[str] = Field(default=None, max_length=120)
    bio: Optional[str] = Field(default=None, max_length=500)
    city: Optional[str] = Field(default=None, max_length=100)


class SettingsUpdateIn(BaseModel):
    language: Optional[str] = Field(default=None, pattern=r"^(?:ar|en)$")
    notifications_enabled: Optional[bool] = None


@router.get("/me")
def me(user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    user = db.get(User, user_id)
    if not user:
        raise AppError(401, "UNAUTHORIZED", "User not found.")
    return ok(auth_service.user_to_dict(user))


@router.put("/preferences", status_code=204)
def put_preferences(
    body: PreferencesIn,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    preferences_service.save_preferences(db, user_id, body)
    return Response(status_code=204)


@router.get("/preferences")
def get_preferences(
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    prefs = preferences_service.get_preferences(db, user_id)
    return ok(prefs or {})


@router.patch("/me")
def update_profile(
    body: ProfileUpdateIn,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    user = db.get(User, user_id)
    if not user:
        raise AppError(401, "UNAUTHORIZED", "User not found.")

    if body.full_name is not None:
        user.full_name = body.full_name.strip()
    if body.bio is not None:
        user.bio = body.bio.strip()
    if body.city is not None:
        user.city = body.city.strip()

    db.commit()
    db.refresh(user)
    return ok(auth_service.user_to_dict(user))


@router.put("/me/avatar")
def upload_avatar(
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
    avatar: UploadFile = File(...),
):
    user = db.get(User, user_id)
    if not user:
        raise AppError(401, "UNAUTHORIZED", "User not found.")

    items = storage_service.read_images([avatar], field="avatar", max_files=1)
    if not items:
        raise AppError(422, "VALIDATION_ERROR", "Avatar image is required.", {"avatar": "REQUIRED"})

    urls = storage_service.upload_images(items, folder="avatars")
    user.avatar = urls[0]
    db.commit()

    return ok({"avatar": user.avatar})


@router.get("/settings")
def get_settings(
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    user = db.get(User, user_id)
    if not user:
        raise AppError(401, "UNAUTHORIZED", "User not found.")
    lang = user.preferences.language if user.preferences and user.preferences.language else "en"
    return ok({
        "language": lang,
        "notifications_enabled": user.notifications_enabled,
    })


@router.patch("/settings")
def patch_settings(
    body: SettingsUpdateIn,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    user = db.get(User, user_id)
    if not user:
        raise AppError(401, "UNAUTHORIZED", "User not found.")

    if body.notifications_enabled is not None:
        user.notifications_enabled = body.notifications_enabled

    if body.language is not None:
        if user.preferences:
            user.preferences.language = body.language
        else:
            preferences_service.save_preferences(
                db, user_id, PreferencesIn(language=body.language)  # type: ignore
            )

    db.commit()
    db.refresh(user)
    lang = user.preferences.language if user.preferences and user.preferences.language else "en"
    return ok({
        "language": lang,
        "notifications_enabled": user.notifications_enabled,
    })


@router.post("/me/deletion-request", status_code=202)
def request_account_deletion(
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    existing = db.get(DeletionRequest, user_id)
    if existing:
        raise AppError(
            409,
            "DELETION_ALREADY_REQUESTED",
            "Account deletion was already requested.",
        )

    db.add(DeletionRequest(user_id=user_id, status="requested"))
    auth_service._revoke_all_sessions(db, user_id)
    db.commit()

    return ok({"status": "requested"})
