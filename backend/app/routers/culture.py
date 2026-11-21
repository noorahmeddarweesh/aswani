"""
app/routers/culture.py
──────────────────────
Cultural stories, themes, and reading list endpoints.
"""
from typing import Optional
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.deps import (
    Pagination,
    get_current_user_id,
    get_db,
    optional_user_id,
)
from app.core.responses import ok, paginated
from app.services import culture_service

router = APIRouter(prefix="/culture", tags=["Culture"])


@router.get("/home")
def get_culture_home(
    user_id: Optional[str] = Depends(optional_user_id),
    db: Session = Depends(get_db),
):
    result = culture_service.get_culture_home(db, user_id)
    return ok(result)


@router.get("/stories")
def list_stories(
    theme: Optional[str] = None,
    pg: Pagination = Depends(),
    user_id: Optional[str] = Depends(optional_user_id),
    db: Session = Depends(get_db),
):
    items, total = culture_service.list_stories(
        db, user_id, theme, pg.page, pg.limit
    )
    return paginated(items, page=pg.page, limit=pg.limit, total=total)


@router.get("/stories/{story_id}")
def get_story(
    story_id: str,
    user_id: Optional[str] = Depends(optional_user_id),
    db: Session = Depends(get_db),
):
    story = culture_service.get_story(db, user_id, story_id)
    return ok(story)


@router.post("/stories/{story_id}/save")
def save_story(
    story_id: str,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    result = culture_service.save_story(db, user_id, story_id)
    return ok(result)


@router.delete("/stories/{story_id}/save")
def unsave_story(
    story_id: str,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    result = culture_service.unsave_story(db, user_id, story_id)
    return ok(result)


@router.get("/saved")
def list_saved_stories(
    pg: Pagination = Depends(),
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    items, total = culture_service.list_saved_stories(
        db, user_id, pg.page, pg.limit
    )
    return paginated(items, page=pg.page, limit=pg.limit, total=total)
