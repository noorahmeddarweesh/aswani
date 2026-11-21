"""
app/services/preferences_service.py
───────────────────────────────────
Business logic for saving and retrieving onboarding user preferences.
"""
from __future__ import annotations

from typing import Optional
from sqlalchemy.orm import Session

from app.db.models import User, UserPreferences
from app.schemas.preferences import PreferencesIn

LIST_FIELDS = ("interests", "travel_styles", "needs")


def save_preferences(db: Session, user_id: str, body: PreferencesIn) -> None:
    """Save or update user personalization preferences."""
    data = body.model_dump()
    # Normalize list fields: convert null to [], deduplicate while preserving order
    for key in LIST_FIELDS:
        items = data.get(key) or []
        data[key] = list(dict.fromkeys(items))

    prefs = db.get(UserPreferences, user_id)
    if prefs is None:
        prefs = UserPreferences(user_id=user_id, **data)
        db.add(prefs)
    else:
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
