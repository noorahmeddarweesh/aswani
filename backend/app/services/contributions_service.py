"""
app/services/contributions_service.py
─────────────────────────────────────
Business logic for user place contributions and editing submissions.
"""
from __future__ import annotations

from typing import Optional
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.errors import AppError
from app.core.security import utcnow
from app.core.validators import normalize_phone
from app.db.models import Contribution

VALID_CATEGORIES = {
    "restaurant", "cafe", "entertainment", "maintenance", "clinic", "other"
}


def contribution_to_dict(c: Contribution) -> dict:
    return {
        "id": c.id,
        "category": c.category,
        "name": c.name,
        "description": c.description,
        "address": c.address,
        "contact_number": c.contact_number,
        "photos": c.photos or [],
        "status": c.status,
        "points_awarded": c.points_awarded,
        "created_at": c.created_at.isoformat() if c.created_at else None,
        "updated_at": c.updated_at.isoformat() if c.updated_at else None,
    }


def create_contribution(
    db: Session,
    user_id: str,
    category: str,
    name: str,
    description: str,
    address: str,
    contact_number: Optional[str],
    photos: list[str],
) -> dict:
    if category not in VALID_CATEGORIES:
        raise AppError(
            422,
            "VALIDATION_ERROR",
            "Invalid contribution category.",
            {"category": "INVALID_CATEGORY"},
        )

    norm_contact = None
    if contact_number and contact_number.strip():
        try:
            norm_contact = normalize_phone(contact_number)
        except ValueError:
            raise AppError(
                422,
                "VALIDATION_ERROR",
                "Invalid Egyptian contact number",
                {"contact_number": "INVALID_PHONE"},
            )

    contrib = Contribution(
        user_id=user_id,
        category=category,
        name=name.strip(),
        description=description.strip(),
        address=address.strip(),
        contact_number=norm_contact,
        photos=photos,
        status="pending",
        points_awarded=0,
    )
    db.add(contrib)
    db.commit()

    return {"id": contrib.id, "status": "pending"}


def list_contributions_mine(
    db: Session, user_id: str, page: int, limit: int
) -> tuple[list[dict], int]:
    stmt = (
        select(Contribution)
        .where(Contribution.user_id == user_id)
        .order_by(Contribution.created_at.desc())
    )
    total = db.scalar(select(func.count()).select_from(stmt.subquery())) or 0
    contribs = db.scalars(stmt.offset((page - 1) * limit).limit(limit)).all()

    items = [
        {
            "id": c.id,
            "category": c.category,
            "name": c.name,
            "status": c.status,
            "points_awarded": c.points_awarded,
            "created_at": c.created_at.isoformat() if c.created_at else None,
        }
        for c in contribs
    ]
    return items, total


def get_contribution(db: Session, user_id: str, contribution_id: str) -> dict:
    contrib = db.get(Contribution, contribution_id)
    if not contrib:
        raise AppError(404, "CONTRIBUTION_NOT_FOUND", "Contribution not found.")

    if contrib.user_id != user_id:
        raise AppError(403, "FORBIDDEN", "You can only view your own contributions.")

    return contribution_to_dict(contrib)


def update_contribution(
    db: Session,
    user_id: str,
    contribution_id: str,
    category: str,
    name: str,
    description: str,
    address: str,
    contact_number: Optional[str],
    keep_photos: list[str],
    new_photos: list[str],
) -> dict:
    contrib = db.get(Contribution, contribution_id)
    if not contrib:
        raise AppError(404, "CONTRIBUTION_NOT_FOUND", "Contribution not found.")

    if contrib.user_id != user_id:
        raise AppError(403, "FORBIDDEN", "You can only edit your own contributions.")

    if category not in VALID_CATEGORIES:
        raise AppError(
            422,
            "VALIDATION_ERROR",
            "Invalid contribution category.",
            {"category": "INVALID_CATEGORY"},
        )

    all_photos = [p for p in keep_photos if p] + new_photos
    if len(all_photos) > 6:
        raise AppError(422, "TOO_MANY_PHOTOS", "Maximum 6 photos allowed.")

    norm_contact = None
    if contact_number and contact_number.strip():
        try:
            norm_contact = normalize_phone(contact_number)
        except ValueError:
            raise AppError(
                422,
                "VALIDATION_ERROR",
                "Invalid Egyptian contact number",
                {"contact_number": "INVALID_PHONE"},
            )

    contrib.category = category
    contrib.name = name.strip()
    contrib.description = description.strip()
    contrib.address = address.strip()
    contrib.contact_number = norm_contact
    contrib.photos = all_photos
    contrib.status = "pending"  # reset to pending on update
    contrib.updated_at = utcnow()

    db.commit()
    db.refresh(contrib)

    return contribution_to_dict(contrib)
