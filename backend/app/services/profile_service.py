"""
app/services/profile_service.py
───────────────────────────────
Business logic for user Profile screen, aggregate stats, contributions summary,
my posts, and polymorphic saved content (places + stories).
"""
from __future__ import annotations

from typing import Optional
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.errors import AppError
from app.db.models import (
    Bookmark,
    Contribution,
    GuideRequest,
    Place,
    PlaceReport,
    Post,
    Story,
    StorySave,
    User,
)
from app.services.culture_service import story_summary
from app.services.places_service import place_to_dict


def get_profile(db: Session, user_id: str) -> dict:
    user = db.get(User, user_id)
    if not user:
        raise AppError(401, "UNAUTHORIZED", "User not found.")

    # 1. Stats
    saved_places_cnt = (
        db.scalar(select(func.count(Bookmark.place_id)).where(Bookmark.user_id == user_id))
        or 0
    )
    saved_stories_cnt = (
        db.scalar(select(func.count(StorySave.story_id)).where(StorySave.user_id == user_id))
        or 0
    )
    posts_cnt = (
        db.scalar(select(func.count(Post.id)).where(Post.user_id == user_id))
        or 0
    )

    # Points = sum of points_awarded where status = accepted on reports and contributions
    report_points = (
        db.scalar(
            select(func.coalesce(func.sum(PlaceReport.points_awarded), 0)).where(
                PlaceReport.user_id == user_id, PlaceReport.status == "accepted"
            )
        )
        or 0
    )
    contrib_points = (
        db.scalar(
            select(func.coalesce(func.sum(Contribution.points_awarded), 0)).where(
                Contribution.user_id == user_id, Contribution.status == "accepted"
            )
        )
        or 0
    )
    total_points = int(report_points + contrib_points)

    # 2. Saved preview (up to 3 items)
    saved_previews: list[dict] = []
    recent_bookmarks = (
        db.scalars(
            select(Place)
            .join(Bookmark, Bookmark.place_id == Place.id)
            .where(Bookmark.user_id == user_id)
            .order_by(Bookmark.created_at.desc())
            .limit(3)
        ).all()
    )
    for p in recent_bookmarks:
        saved_previews.append({
            "type": "place",
            "id": p.id,
            "image": p.image or "",
        })

    if len(saved_previews) < 3:
        needed = 3 - len(saved_previews)
        recent_stories = (
            db.scalars(
                select(Story)
                .join(StorySave, StorySave.story_id == Story.id)
                .where(StorySave.user_id == user_id)
                .order_by(StorySave.created_at.desc())
                .limit(needed)
            ).all()
        )
        for s in recent_stories:
            saved_previews.append({
                "type": "story",
                "id": s.id,
                "image": s.cover_image or "",
            })

    # 3. Contributions summary
    reports_under_review = (
        db.scalar(
            select(func.count(PlaceReport.id)).where(
                PlaceReport.user_id == user_id, PlaceReport.status == "pending"
            )
        )
        or 0
    )
    added_activities = (
        db.scalar(
            select(func.count(Contribution.id)).where(Contribution.user_id == user_id)
        )
        or 0
    )
    guide_requests_pending = (
        db.scalar(
            select(func.count(GuideRequest.id)).where(
                GuideRequest.user_id == user_id, GuideRequest.status == "pending"
            )
        )
        or 0
    )

    persona = user.preferences.persona if user.preferences else None

    return {
        "id": user.id,
        "full_name": user.full_name,
        "avatar": user.avatar,
        "persona": persona,
        "city": user.city,
        "bio": user.bio,
        "stats": {
            "saved_places": saved_places_cnt,
            "saved_stories": saved_stories_cnt,
            "posts": posts_cnt,
            "points": total_points,
        },
        "saved_preview": saved_previews,
        "contributions": {
            "reports_under_review": reports_under_review,
            "added_activities": added_activities,
            "guide_requests_pending": guide_requests_pending,
        },
    }


def get_my_posts(
    db: Session, user_id: str, page: int, limit: int
) -> tuple[list[dict], int]:
    from app.services.community_service import list_posts
    return list_posts(db, user_id=user_id, category=None, sort="new", page=page, limit=limit)


def get_saved_content(
    db: Session,
    user_id: str,
    item_type: Optional[str],
    page: int,
    limit: int,
) -> tuple[list[dict], int]:
    if item_type == "place":
        places_q = (
            select(Place)
            .join(Bookmark, Bookmark.place_id == Place.id)
            .where(Bookmark.user_id == user_id)
            .order_by(Bookmark.created_at.desc())
        )
        total = db.scalar(select(func.count()).select_from(places_q.subquery())) or 0
        places = db.scalars(places_q.offset((page - 1) * limit).limit(limit)).all()
        return [
            {"type": "place", "place": place_to_dict(p, is_bookmarked=True)}
            for p in places
        ], total

    elif item_type == "story":
        stories_q = (
            select(Story)
            .join(StorySave, StorySave.story_id == Story.id)
            .where(StorySave.user_id == user_id)
            .order_by(StorySave.created_at.desc())
        )
        total = db.scalar(select(func.count()).select_from(stories_q.subquery())) or 0
        stories = db.scalars(stories_q.offset((page - 1) * limit).limit(limit)).all()
        return [
            {"type": "story", "story": story_summary(s, is_saved=True)}
            for s in stories
        ], total

    # Polymorphic / combined: places and stories
    places_rows = db.scalars(
        select(Place)
        .join(Bookmark, Bookmark.place_id == Place.id)
        .where(Bookmark.user_id == user_id)
    ).all()
    stories_rows = db.scalars(
        select(Story)
        .join(StorySave, StorySave.story_id == Story.id)
        .where(StorySave.user_id == user_id)
    ).all()

    combined: list[dict] = [
        {"type": "place", "place": place_to_dict(p, is_bookmarked=True)}
        for p in places_rows
    ] + [
        {"type": "story", "story": story_summary(s, is_saved=True)}
        for s in stories_rows
    ]
    total = len(combined)
    offset = (page - 1) * limit
    return combined[offset : offset + limit], total
