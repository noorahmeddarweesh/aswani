"""
app/routers/guides.py
─────────────────────
Local guides directory, booking requests, and guide partner applications.
"""
from typing import Optional
from fastapi import APIRouter, Depends, File, Form, Query, UploadFile
from sqlalchemy.orm import Session

from app.core.deps import Pagination, get_current_user_id, get_db
from app.core.responses import ok, paginated
from app.schemas.guides import GuideRequestIn, Specialty
from app.services import guides_service, storage_service

router = APIRouter(tags=["Local Guides"])


# ─── Guides Directory ─────────────────────────────────────────────────────────

@router.get("/guides")
def list_guides(
    specialty: Optional[Specialty] = None,
    q: Optional[str] = Query(default=None, max_length=100),
    pg: Pagination = Depends(),
    db: Session = Depends(get_db),
):
    items, total = guides_service.list_guides(
        db, specialty, q, pg.page, pg.limit
    )
    return paginated(items, page=pg.page, limit=pg.limit, total=total)


@router.get("/guides/{guide_id}")
def get_guide(guide_id: str, db: Session = Depends(get_db)):
    guide = guides_service.get_guide(db, guide_id)
    return ok(guide)


# ─── Guide Requests ───────────────────────────────────────────────────────────

@router.post("/guide-requests", status_code=201)
def create_guide_request(
    body: GuideRequestIn,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    result = guides_service.create_guide_request(db, user_id, body)
    return ok(result)


@router.get("/guide-requests/mine")
def list_my_guide_requests(
    pg: Pagination = Depends(),
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    items, total = guides_service.list_guide_requests_mine(
        db, user_id, pg.page, pg.limit
    )
    return paginated(items, page=pg.page, limit=pg.limit, total=total)


# ─── Guide Applications ───────────────────────────────────────────────────────

@router.post("/guide-applications", status_code=201)
def create_guide_application(
    full_name: str = Form(..., min_length=2, max_length=120),
    languages: list[str] = Form(...),
    specialties: list[str] = Form(...),
    durations: list[str] = Form(...),
    bio: str = Form(..., min_length=10, max_length=2000),
    contact: str = Form(..., min_length=8, max_length=20),
    profile_photo: Optional[UploadFile] = File(default=None),
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    photo_url: Optional[str] = None
    if profile_photo and profile_photo.filename:
        items = storage_service.read_images([profile_photo], field="profile_photo", max_files=1)
        if items:
            urls = storage_service.upload_images(items, folder="guides")
            photo_url = urls[0]

    result = guides_service.create_guide_application(
        db=db,
        user_id=user_id,
        full_name=full_name,
        languages=languages,
        specialties=specialties,
        bio=bio,
        durations=durations,
        contact=contact,
        profile_photo_url=photo_url,
    )
    return ok(result)
