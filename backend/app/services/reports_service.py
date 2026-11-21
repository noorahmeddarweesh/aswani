"""
app/services/reports_service.py
───────────────────────────────
Business logic for reporting places and viewing user-submitted reports.
"""
from __future__ import annotations

from typing import Optional
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.errors import AppError
from app.db.models import Place, PlaceReport

VALID_REASONS = {
    "not_exist",
    "permanently_closed",
    "temporarily_closed",
    "incorrect_location",
    "incorrect_information",
    "other",
}


def create_place_report(
    db: Session,
    user_id: str,
    place_id: str,
    reason: str,
    details: str,
    photo_url: Optional[str] = None,
) -> dict:
    place = db.get(Place, place_id)
    if not place:
        raise AppError(404, "PLACE_NOT_FOUND", f"Place '{place_id}' not found.")

    if reason not in VALID_REASONS:
        raise AppError(
            422,
            "VALIDATION_ERROR",
            "Invalid report reason",
            {"reason": "INVALID_REASON"},
        )

    clean_details = details.strip()
    if not (1 <= len(clean_details) <= 1000):
        raise AppError(
            422,
            "VALIDATION_ERROR",
            "Details must be between 1 and 1000 characters",
            {"details": "INVALID_LENGTH"},
        )

    report = PlaceReport(
        user_id=user_id,
        place_id=place_id,
        reason=reason,
        details=clean_details,
        photo=photo_url,
        status="pending",
        points_awarded=0,
    )
    db.add(report)
    db.commit()

    return {
        "id": report.id,
        "status": "pending",
        "points_pending": 25,
    }


def list_place_reports_mine(
    db: Session, user_id: str, page: int, limit: int
) -> tuple[list[dict], int]:
    stmt = (
        select(PlaceReport)
        .where(PlaceReport.user_id == user_id)
        .order_by(PlaceReport.created_at.desc())
    )
    total = db.scalar(select(func.count()).select_from(stmt.subquery())) or 0
    reports = db.scalars(
        stmt.offset((page - 1) * limit).limit(limit)
    ).all()

    items = []
    for r in reports:
        p = r.place
        items.append({
            "id": r.id,
            "place": {
                "id": p.id if p else r.place_id,
                "name_en": p.name_en if p else "",
                "name_ar": p.name_ar if p else "",
                "image": p.image if p else "",
            },
            "reason": r.reason,
            "status": r.status,
            "points_awarded": r.points_awarded,
            "created_at": r.created_at.isoformat() if r.created_at else None,
        })
    return items, total
