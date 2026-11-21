"""
app/routers/reports.py
──────────────────────
Place report submissions and history for authenticated users.
"""
from typing import Optional
from fastapi import APIRouter, Depends, File, Form, UploadFile
from sqlalchemy.orm import Session

from app.core.deps import Pagination, get_current_user_id, get_db
from app.core.responses import ok, paginated
from app.schemas.guides import ReportReason
from app.services import reports_service, storage_service

router = APIRouter(prefix="/place-reports", tags=["Place Reports"])


@router.post("", status_code=201)
def create_place_report(
    place_id: str = Form(..., min_length=1, max_length=64),
    reason: ReportReason = Form(...),
    details: str = Form(..., min_length=1, max_length=1000),
    photo: Optional[UploadFile] = File(default=None),
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    photo_url: Optional[str] = None
    if photo and photo.filename:
        items = storage_service.read_images([photo], field="photo", max_files=1)
        if items:
            urls = storage_service.upload_images(items, folder="reports")
            photo_url = urls[0]

    result = reports_service.create_place_report(
        db=db,
        user_id=user_id,
        place_id=place_id,
        reason=reason,
        details=details,
        photo_url=photo_url,
    )
    return ok(result)


@router.get("/mine")
def list_my_reports(
    pg: Pagination = Depends(),
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    items, total = reports_service.list_place_reports_mine(
        db, user_id, pg.page, pg.limit
    )
    return paginated(items, page=pg.page, limit=pg.limit, total=total)
