"""
app/services/guides_service.py
──────────────────────────────
Business logic for local guides directory, visitor booking requests,
and guide partner applications.
"""
from __future__ import annotations

import json
from typing import Optional
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app.core.errors import AppError
from app.core.validators import normalize_full_name, normalize_phone
from app.db.models import Guide, GuideApplication, GuideRequest
from app.schemas.guides import GuideRequestIn


def guide_to_dict(g: Guide) -> dict:
    return {
        "id": g.id,
        "full_name": g.full_name,
        "photo": g.photo,
        "city": g.city or "Aswan",
        "tagline": g.tagline or "",
        "languages": g.languages or [],
        "specialties": g.specialties or [],
        "durations": g.durations or [],
        "bio": g.bio or "",
        "is_featured": g.is_featured,
        "is_verified": g.is_verified,
    }


def list_guides(
    db: Session,
    specialty: Optional[str],
    q: Optional[str],
    page: int,
    limit: int,
) -> tuple[list[dict], int]:
    stmt = select(Guide)
    if specialty:
        # Check if specialty exists in JSON array
        stmt = stmt.where(Guide.specialties.contains([specialty]))
    if q and q.strip():
        safe_q = q.strip().replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_")
        like_expr = f"%{safe_q}%"
        stmt = stmt.where(
            or_(
                Guide.full_name.ilike(like_expr, escape="\\"),
                Guide.tagline.ilike(like_expr, escape="\\"),
                Guide.bio.ilike(like_expr, escape="\\"),
            )
        )

    total = db.scalar(select(func.count()).select_from(stmt.subquery())) or 0
    guides = db.scalars(
        stmt.order_by(Guide.is_featured.desc(), Guide.full_name.asc())
        .offset((page - 1) * limit)
        .limit(limit)
    ).all()

    return [guide_to_dict(g) for g in guides], total


def get_guide(db: Session, guide_id: str) -> dict:
    guide = db.get(Guide, guide_id)
    if not guide:
        raise AppError(404, "GUIDE_NOT_FOUND", f"Guide '{guide_id}' not found.")
    return guide_to_dict(guide)


def create_guide_request(
    db: Session, user_id: str, body: GuideRequestIn
) -> dict:
    guide = db.get(Guide, body.guide_id)
    if not guide:
        raise AppError(404, "GUIDE_NOT_FOUND", "Guide not found.")

    req = GuideRequest(
        user_id=user_id,
        guide_id=body.guide_id,
        date=body.date,
        duration=body.duration,
        duration_hours=body.duration_hours,
        start_time=body.start_time,
        group_size=body.group_size,
        language=body.language,
        interests=body.interests or [],
        notes=body.notes,
        status="pending",
    )
    db.add(req)
    db.commit()

    return {"id": req.id, "status": "pending"}


def list_guide_requests_mine(
    db: Session, user_id: str, page: int, limit: int
) -> tuple[list[dict], int]:
    stmt = (
        select(GuideRequest)
        .where(GuideRequest.user_id == user_id)
        .order_by(GuideRequest.created_at.desc())
    )
    total = db.scalar(select(func.count()).select_from(stmt.subquery())) or 0
    requests = db.scalars(
        stmt.offset((page - 1) * limit).limit(limit)
    ).all()

    items = []
    for r in requests:
        g = r.guide
        items.append({
            "id": r.id,
            "guide": {
                "id": g.id if g else r.guide_id,
                "full_name": g.full_name if g else "",
                "photo": g.photo if g else None,
            },
            "date": str(r.date),
            "duration": r.duration,
            "duration_hours": r.duration_hours,
            "start_time": r.start_time,
            "group_size": r.group_size,
            "language": r.language,
            "interests": r.interests or [],
            "status": r.status,
            "created_at": r.created_at.isoformat() if r.created_at else None,
        })
    return items, total


def create_guide_application(
    db: Session,
    user_id: str,
    full_name: str,
    languages: list[str],
    specialties: list[str],
    bio: str,
    durations: list[str],
    contact: str,
    profile_photo_url: Optional[str] = None,
) -> dict:
    existing = db.scalar(
        select(GuideApplication).where(GuideApplication.user_id == user_id)
    )
    if existing:
        raise AppError(
            409,
            "ALREADY_APPLIED",
            "You have already submitted an application to become a guide.",
        )

    try:
        norm_contact = normalize_phone(contact)
    except ValueError:
        raise AppError(
            422,
            "VALIDATION_ERROR",
            "Invalid Egyptian contact number",
            {"contact": "INVALID_PHONE"},
        )

    app = GuideApplication(
        user_id=user_id,
        full_name=normalize_full_name(full_name),
        languages=languages,
        specialties=specialties,
        bio=bio,
        durations=durations,
        contact=norm_contact,
        profile_photo=profile_photo_url,
        status="pending",
    )
    db.add(app)
    db.commit()

    return {"id": app.id, "status": "pending"}
