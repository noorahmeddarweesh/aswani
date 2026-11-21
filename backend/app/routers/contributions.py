"""
app/routers/contributions.py
────────────────────────────
User activity and place contributions endpoints.
"""
from typing import Optional
from fastapi import APIRouter, Depends, File, Form, UploadFile
from sqlalchemy.orm import Session

from app.core.deps import Pagination, get_current_user_id, get_db
from app.core.responses import ok, paginated
from app.schemas.contributions import ContributionCategory
from app.services import contributions_service, storage_service

router = APIRouter(prefix="/contributions", tags=["Contributions"])


@router.post("", status_code=201)
def create_contribution(
    category: ContributionCategory = Form(...),
    name: str = Form(..., min_length=2, max_length=200),
    description: str = Form(..., min_length=5, max_length=3000),
    address: str = Form(..., min_length=5, max_length=300),
    contact_number: Optional[str] = Form(default=None, max_length=20),
    photos: list[UploadFile] = File(default=[]),
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    photo_urls: list[str] = []
    if photos:
        items = storage_service.read_images(photos, field="photos", max_files=6)
        if items:
            photo_urls = storage_service.upload_images(items, folder="contributions")

    result = contributions_service.create_contribution(
        db=db,
        user_id=user_id,
        category=category,
        name=name,
        description=description,
        address=address,
        contact_number=contact_number,
        photos=photo_urls,
    )
    return ok(result)


@router.get("/mine")
def list_my_contributions(
    pg: Pagination = Depends(),
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    items, total = contributions_service.list_contributions_mine(
        db, user_id, pg.page, pg.limit
    )
    return paginated(items, page=pg.page, limit=pg.limit, total=total)


@router.get("/{contribution_id}")
def get_contribution(
    contribution_id: str,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    contrib = contributions_service.get_contribution(db, user_id, contribution_id)
    return ok(contrib)


@router.patch("/{contribution_id}")
def update_contribution(
    contribution_id: str,
    category: ContributionCategory = Form(...),
    name: str = Form(..., min_length=2, max_length=200),
    description: str = Form(..., min_length=5, max_length=3000),
    address: str = Form(..., min_length=5, max_length=300),
    contact_number: Optional[str] = Form(default=None, max_length=20),
    keep_photos: list[str] = Form(default=[]),
    photos: list[UploadFile] = File(default=[]),
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    new_urls: list[str] = []
    if photos:
        items = storage_service.read_images(photos, field="photos", max_files=6)
        if items:
            new_urls = storage_service.upload_images(items, folder="contributions")

    contrib = contributions_service.update_contribution(
        db=db,
        user_id=user_id,
        contribution_id=contribution_id,
        category=category,
        name=name,
        description=description,
        address=address,
        contact_number=contact_number,
        keep_photos=keep_photos,
        new_photos=new_urls,
    )
    return ok(contrib)
