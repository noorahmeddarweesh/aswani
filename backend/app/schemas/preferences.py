"""
app/schemas/preferences.py
──────────────────────────
Pydantic schemas for user onboarding personalization & preferences.
"""
from __future__ import annotations

from typing import Literal, Optional
from pydantic import BaseModel, Field

Persona = Literal["visitor", "newcomer", "resident"]
Purpose = Literal["tourism", "living", "studying", "work", "family", "other"]
StayLength = Literal[
    "few_days", "week", "month", "several_months", "long_term", "not_sure"
]
Interest = Literal[
    "historical",
    "nubian",
    "nature",
    "local",
    "food",
    "community",
    "traditional_food",
    "photography",
]
TravelStyle = Literal["calm", "adventurous", "cultural", "social", "hidden", "mix"]
Companions = Literal[
    "solo", "friends", "family", "partner", "group", "may_change"
]
Need = Literal[
    "finding_places",
    "getting_around",
    "local_recommendations",
    "local_guides",
    "activities",
    "local_services",
]
Language = Literal["ar", "en"]


class PreferencesIn(BaseModel):
    persona: Optional[Persona] = None
    purpose: Optional[Purpose] = None
    stay_length: Optional[StayLength] = None
    interests: Optional[list[Interest]] = Field(default=None, max_length=8)
    travel_styles: Optional[list[TravelStyle]] = Field(default=None, max_length=6)
    companions: Optional[Companions] = None
    needs: Optional[list[Need]] = Field(default=None, max_length=6)
    language: Optional[Language] = None
