"""
app/routers/bookmarks.py
────────────────────────
Saved places / bookmarks endpoints for authenticated users.
"""
from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.core.deps import Pagination, get_current_user_id, get_db
from app.core.responses import ok, paginated
from app.services import places_service

router = APIRouter(prefix="/bookmarks", tags=["Bookmarks"])


class BookmarkIn(BaseModel):
    place_id: str = Field(min_length=1, max_length=64)


@router.post("", status_code=201)
def add_bookmark(
    body: BookmarkIn,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    result = places_service.add_bookmark(db, user_id, body.place_id)
    return ok(result)


@router.delete("/{place_id}")
def remove_bookmark(
    place_id: str,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    result = places_service.remove_bookmark(db, user_id, place_id)
    return ok(result)


@router.get("")
def list_bookmarks(
    pg: Pagination = Depends(),
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    items, total = places_service.list_bookmarks(db, user_id, pg.page, pg.limit)
    return paginated(items, page=pg.page, limit=pg.limit, total=total)
