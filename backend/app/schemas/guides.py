"""
app/schemas/guides.py
─────────────────────
Pydantic schemas and types for Local Guides, Guide Requests, and Guide Applications.
"""
from __future__ import annotations

from datetime import date, datetime
from typing import Literal, Optional
from zoneinfo import ZoneInfo
from pydantic import BaseModel, Field, field_validator

from app.core.validators import normalize_phone

GuideDuration = Literal["few_hours", "one_day", "multiple_days"]
RequestDuration = Literal["few_hours", "one_day", "two_days", "three_days", "custom"]
Specialty = Literal[
    "nubian_culture",
    "historical_sites",
    "nile",
    "photography",
    "local_experiences",
]
GuideLanguage = Literal["ar", "en", "fr", "de", "it", "es"]
ReportReason = Literal[
    "not_exist",
    "permanently_closed",
    "temporarily_closed",
    "incorrect_location",
    "incorrect_information",
    "other",
]


class GuideRequestIn(BaseModel):
    guide_id: str = Field(min_length=1)
    date: date
    duration: RequestDuration
    duration_hours: Optional[int] = Field(default=None, ge=1, le=12)
    start_time: str = Field(pattern=r"^\d{2}:\d{2}$")  # HH:mm
    group_size: int = Field(ge=1, le=20)
    language: GuideLanguage
    interests: Optional[list[Specialty]] = Field(default=None, max_length=5)
    notes: Optional[str] = Field(default=None, max_length=1000)

    @field_validator("date")
    @classmethod
    def _validate_date_not_in_past(cls, v: date) -> date:
        try:
            today_cairo = datetime.now(ZoneInfo("Africa/Cairo")).date()
        except Exception:
            today_cairo = datetime.utcnow().date()
        if v < today_cairo:
            raise ValueError("DATE_IN_PAST")
        return v

    @field_validator("duration_hours")
    @classmethod
    def _validate_custom_duration(cls, v: Optional[int], info) -> Optional[int]:
        duration = info.data.get("duration")
        if duration == "custom" and (v is None or v < 1):
            raise ValueError("REQUIRED_FOR_CUSTOM_DURATION")
        return v
