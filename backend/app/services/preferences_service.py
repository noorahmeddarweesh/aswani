"""
app/services/preferences_service.py
───────────────────────────────────
Business logic for saving and retrieving onboarding user preferences.
"""
from __future__ import annotations

from typing import Optional, Union
from sqlalchemy.orm import Session

from app.core.errors import AppError
from app.db.models import User, UserPreferences
from app.schemas.preferences import PreferencesIn

LIST_FIELDS = ("interests", "travel_styles", "needs")


def save_preferences(db: Session, user: Union[User, str], body: PreferencesIn) -> None:
    """
    Save or update user personalization preferences with full replacement (PUT) semantics.
    Accepts User instance (or user_id string for existing settings compatibility).
    """
    # Resolve User instance if user_id string was passed
    if isinstance(user, str):
        user_obj = db.get(User, user)
        if not user_obj:
            raise AppError(401, "UNAUTHORIZED", "Missing, expired or invalid token")
        user = user_obj

    data = body.model_dump()

    # Convert null list fields to [] and deduplicate while keeping order
    for key in LIST_FIELDS:
        items = data.get(key) or []
        data[key] = list(dict.fromkeys(items))

    prefs = user.preferences
    if prefs is None:
        # Create row if it doesn't exist
        prefs = UserPreferences(user_id=user.id, **data)
        db.add(prefs)
    else:
        # Full replacement
        for key, value in data.items():
            setattr(prefs, key, value)

    db.commit()


def get_preferences(db: Session, user_id: str) -> Optional[dict]:
    """Retrieve user personalization preferences."""
    prefs = db.get(UserPreferences, user_id)
    if not prefs:
        return None
    return {
        "persona": prefs.persona,
        "purpose": prefs.purpose,
        "stay_length": prefs.stay_length,
        "interests": prefs.interests or [],
        "travel_styles": prefs.travel_styles or [],
        "companions": prefs.companions,
        "needs": prefs.needs or [],
        "language": prefs.language or "en",
    }
