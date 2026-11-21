"""
app/routers/profile.py
──────────────────────
Aggregated profile metrics and unified saved content (places & stories).
"""
from typing import Literal, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.deps import Pagination, get_current_user_id, get_db
from app.core.responses import ok, paginated
from app.services import profile_service

router = APIRouter(tags=["Profile & Saved"])

SavedType = Literal["place", "story"]


@router.get("/users/me/profile")
def get_user_profile(
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    result = profile_service.get_profile(db, user_id)
    return ok(result)


@router.get("/saved")
def get_saved(
    type: Optional[SavedType] = Query(default=None),
    pg: Pagination = Depends(),
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    items, total = profile_service.get_saved_content(
        db, user_id=user_id, item_type=type, page=pg.page, limit=pg.limit
    )
    return paginated(items, page=pg.page, limit=pg.limit, total=total)
