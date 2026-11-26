"""
app/routers/places.py
─────────────────────
Places exploration, search, curated highlights, and detailed place views.
"""
from typing import Literal, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.deps import Pagination, get_db, optional_user_id
from app.core.responses import ok, paginated
from app.services import places_service

router = APIRouter(prefix="/places", tags=["Places"])

Category = Literal["history", "nubian", "nature", "food"]


@router.get("")
def list_places(
    category: Optional[Category] = None,
    q: Optional[str] = Query(default=None, max_length=100),
    pg: Pagination = Depends(),
    user_id: Optional[str] = Depends(optional_user_id),
    db: Session = Depends(get_db),
):
    items, total = places_service.list_places(
        db, user_id, category, q, pg.page, pg.limit
    )
    return paginated(items, page=pg.page, limit=pg.limit, total=total)


@router.get("/curated")
def curated(
    user_id: Optional[str] = Depends(optional_user_id),
    db: Session = Depends(get_db),
):
    items = places_service.curated(db, user_id)
    return ok(items)


@router.get("/{place_id}")
def get_place(
    place_id: str,
    user_id: Optional[str] = Depends(optional_user_id),
    db: Session = Depends(get_db),
):
    place = places_service.get_place(db, user_id, place_id)
    return ok(place)
