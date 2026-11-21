"""
app/services/culture_service.py
───────────────────────────────
Business logic for Culture home, themes, bilingual stories, and saved reads.
"""
from __future__ import annotations

from typing import Optional
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.errors import AppError
from app.db.models import CultureTheme, Story, StorySave


def story_summary(s: Story, is_saved: bool = False) -> dict:
    return {
        "id": s.id,
        "theme": s.theme,
        "title_en": s.title_en,
        "title_ar": s.title_ar,
        "label_en": s.label_en or "",
        "label_ar": s.label_ar or "",
        "location_en": s.location_en,
        "location_ar": s.location_ar,
        "cover_image": s.cover_image or "",
        "read_minutes": s.read_minutes,
        "is_sample": s.is_sample,
        "is_saved": is_saved,
    }


def _saved_story_ids(db: Session, user_id: Optional[str], story_ids: list[str]) -> set[str]:
    if not user_id or not story_ids:
        return set()
    return set(
        db.scalars(
            select(StorySave.story_id).where(
                StorySave.user_id == user_id, StorySave.story_id.in_(story_ids)
            )
        ).all()
    )


def get_culture_home(db: Session, user_id: Optional[str]) -> dict:
    # 1. Themes
    themes = db.scalars(select(CultureTheme)).all()
    theme_items = [
        {"id": t.id, "title_en": t.title_en, "title_ar": t.title_ar, "image": t.image}
        for t in themes
    ]

    # 2. Featured & Selected Reads
    stories = db.scalars(
        select(Story).order_by(Story.is_featured.desc(), Story.created_at.desc()).limit(6)
    ).all()

    story_ids = [s.id for s in stories]
    saved_ids = _saved_story_ids(db, user_id, story_ids)

    featured_summary = (
        story_summary(stories[0], stories[0].id in saved_ids) if stories else None
    )
    selected_reads = [
        story_summary(s, s.id in saved_ids) for s in stories[1:]
    ]

    return {
        "featured": featured_summary,
        "themes": theme_items,
        "selected_reads": selected_reads,
    }


def list_stories(
    db: Session,
    user_id: Optional[str],
    theme: Optional[str],
    page: int,
    limit: int,
) -> tuple[list[dict], int]:
    stmt = select(Story)
    if theme:
        # Validate theme exists
        valid = db.get(CultureTheme, theme)
        if not valid:
            raise AppError(422, "VALIDATION_ERROR", f"Unknown theme '{theme}'.", {"theme": "UNKNOWN_THEME"})
        stmt = stmt.where(Story.theme == theme)

    total = db.scalar(select(func.count()).select_from(stmt.subquery())) or 0
    stories = db.scalars(
        stmt.order_by(Story.created_at.desc())
        .offset((page - 1) * limit)
        .limit(limit)
    ).all()

    saved_ids = _saved_story_ids(db, user_id, [s.id for s in stories])
    return [story_summary(s, s.id in saved_ids) for s in stories], total


def get_story(db: Session, user_id: Optional[str], story_id: str) -> dict:
    story = db.get(Story, story_id)
    if not story:
        raise AppError(404, "STORY_NOT_FOUND", "Story not found.")

    is_saved = False
    if user_id:
        is_saved = (
            db.scalar(
                select(StorySave.story_id).where(
                    StorySave.user_id == user_id, StorySave.story_id == story_id
                )
            )
            is not None
        )

    data = story_summary(story, is_saved)
    data["blocks"] = story.blocks or []
    return data


def save_story(db: Session, user_id: str, story_id: str) -> dict:
    story = db.get(Story, story_id)
    if not story:
        raise AppError(404, "STORY_NOT_FOUND", "Story not found.")

    existing = db.get(StorySave, (user_id, story_id))
    if not existing:
        db.add(StorySave(user_id=user_id, story_id=story_id))
        db.commit()

    return {"is_saved": True}


def unsave_story(db: Session, user_id: str, story_id: str) -> dict:
    story = db.get(Story, story_id)
    if not story:
        raise AppError(404, "STORY_NOT_FOUND", "Story not found.")

    existing = db.get(StorySave, (user_id, story_id))
    if existing:
        db.delete(existing)
        db.commit()

    return {"is_saved": False}


def list_saved_stories(
    db: Session, user_id: str, page: int, limit: int
) -> tuple[list[dict], int]:
    base_query = (
        select(Story)
        .join(StorySave, StorySave.story_id == Story.id)
        .where(StorySave.user_id == user_id)
    )
    total = db.scalar(select(func.count()).select_from(base_query.subquery())) or 0
    stories = db.scalars(
        base_query.order_by(StorySave.created_at.desc())
        .offset((page - 1) * limit)
        .limit(limit)
    ).all()

    return [story_summary(s, is_saved=True) for s in stories], total
