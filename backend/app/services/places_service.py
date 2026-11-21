"""
app/services/places_service.py
──────────────────────────────
Business logic for places exploration, curated lists, detailed place views,
and user bookmarks.
"""
from __future__ import annotations

from typing import Optional
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app.core.errors import AppError
from app.db.models import Bookmark, Place


def place_to_dict(place: Place, is_bookmarked: bool, is_detailed: bool = False) -> dict:
    """Format Place model to JSON matching mobile API contract."""
    res = {
        "id": place.id,
        "category": place.category,
        "name_en": place.name_en,
        "name_ar": place.name_ar,
        "label_en": place.label_en or "",
        "label_ar": place.label_ar or "",
        "tagline_en": place.tagline_en or "",
        "tagline_ar": place.tagline_ar or "",
        "city_en": place.city_en or "Aswan",
        "city_ar": place.city_ar or "أسوان",
        "image": place.image or "",
        "is_curated": place.is_curated,
        "is_editors_pick": place.is_editors_pick,
        "is_bookmarked": is_bookmarked,
    }
    if is_detailed:
        res["location_en"] = place.location_en or ""
        res["location_ar"] = place.location_ar or ""
        res["about_en"] = place.about_en or ""
        res["about_ar"] = place.about_ar or ""
        res["images"] = place.images or []
        res["facts"] = place.facts or []
    return res


def _bookmarked_ids(
    db: Session, user_id: Optional[str], place_ids: list[str]
) -> set[str]:
    """Batch fetch bookmarked place IDs for a user to avoid N+1 queries."""
    if not user_id or not place_ids:
        return set()
    rows = db.scalars(
        select(Bookmark.place_id).where(
            Bookmark.user_id == user_id, Bookmark.place_id.in_(place_ids)
        )
    ).all()
    return set(rows)


def _get_place_or_404(db: Session, place_id: str) -> Place:
    place = db.get(Place, place_id)
    if not place:
        raise AppError(404, "PLACE_NOT_FOUND", f"Place with id '{place_id}' not found.")
    return place


def list_places(
    db: Session,
    user_id: Optional[str],
    category: Optional[str],
    q: Optional[str],
    page: int,
    limit: int,
) -> tuple[list[dict], int]:
    stmt = select(Place)
    if category:
        stmt = stmt.where(Place.category == category)
    if q and q.strip():
        safe_q = (
            q.strip()
            .replace("\\", "\\\\")
            .replace("%", "\\%")
            .replace("_", "\\_")
        )
        like_expr = f"%{safe_q}%"
        stmt = stmt.where(
            or_(
                Place.name_en.ilike(like_expr, escape="\\"),
                Place.name_ar.ilike(like_expr, escape="\\"),
                Place.label_en.ilike(like_expr, escape="\\"),
                Place.label_ar.ilike(like_expr, escape="\\"),
            )
        )

    total = db.scalar(select(func.count()).select_from(stmt.subquery())) or 0
    places = db.scalars(
        stmt.order_by(Place.is_editors_pick.desc(), Place.name_en.asc())
        .offset((page - 1) * limit)
        .limit(limit)
    ).all()

    bookmarked = _bookmarked_ids(db, user_id, [p.id for p in places])
    return [place_to_dict(p, p.id in bookmarked) for p in places], total


def curated(db: Session, user_id: Optional[str]) -> list[dict]:
    """Return up to 10 curated places for Home screen."""
    places = db.scalars(
        select(Place)
        .where(Place.is_curated.is_(True))
        .order_by(Place.name_en.asc())
        .limit(10)
    ).all()
    bookmarked = _bookmarked_ids(db, user_id, [p.id for p in places])
    return [place_to_dict(p, p.id in bookmarked) for p in places]


def get_place(
    db: Session, user_id: Optional[str], place_id: str
) -> dict:
    place = _get_place_or_404(db, place_id)
    is_bookmarked = False
    if user_id:
        is_bookmarked = (
            db.scalar(
                select(Bookmark.place_id).where(
                    Bookmark.user_id == user_id, Bookmark.place_id == place_id
                )
            )
            is not None
        )
    return place_to_dict(place, is_bookmarked, is_detailed=True)


def add_bookmark(db: Session, user_id: str, place_id: str) -> dict:
    place = _get_place_or_404(db, place_id)
    existing = db.get(Bookmark, (user_id, place_id))
    if not existing:
        db.add(Bookmark(user_id=user_id, place_id=place_id))
        db.commit()
    return place_to_dict(place, True)


def remove_bookmark(db: Session, user_id: str, place_id: str) -> dict:
    place = _get_place_or_404(db, place_id)
    existing = db.get(Bookmark, (user_id, place_id))
    if existing:
        db.delete(existing)
        db.commit()
    return place_to_dict(place, False)


def list_bookmarks(
    db: Session, user_id: str, page: int, limit: int
) -> tuple[list[dict], int]:
    base_query = (
        select(Place)
        .join(Bookmark, Bookmark.place_id == Place.id)
        .where(Bookmark.user_id == user_id)
    )
    total = db.scalar(select(func.count()).select_from(base_query.subquery())) or 0
    places = db.scalars(
        base_query.order_by(Bookmark.created_at.desc())
        .offset((page - 1) * limit)
        .limit(limit)
    ).all()
    return [place_to_dict(p, True) for p in places], total
