"""
app/routers/community.py
────────────────────────
Community feed, user posts, social interactions (likes, bookmarks, comments),
and highlight stories.
"""
from typing import Optional
from fastapi import APIRouter, Depends, File, Form, Response, UploadFile
from sqlalchemy.orm import Session

from app.core.deps import (
    Pagination,
    get_current_user_id,
    get_db,
    optional_user_id,
)
from app.core.responses import ok, paginated
from app.schemas.community import CommentIn, PostCategory, SortMode
from app.services import community_service, storage_service

router = APIRouter(prefix="/community", tags=["Community"])


@router.get("/stories")
def get_highlights(db: Session = Depends(get_db)):
    items = community_service.get_highlights(db)
    return ok(items)


@router.get("/posts/mine")
def list_my_posts(
    pg: Pagination = Depends(),
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    items, total = community_service.list_posts(
        db, user_id=user_id, category=None, sort="new", page=pg.page, limit=pg.limit
    )
    return paginated(items, page=pg.page, limit=pg.limit, total=total)


@router.get("/posts")
def list_posts(
    category: Optional[PostCategory] = None,
    sort: Optional[SortMode] = "new",
    pg: Pagination = Depends(),
    user_id: Optional[str] = Depends(optional_user_id),
    db: Session = Depends(get_db),
):
    items, total = community_service.list_posts(
        db, user_id, category, sort, pg.page, pg.limit
    )
    return paginated(items, page=pg.page, limit=pg.limit, total=total)


@router.post("/posts", status_code=201)
def create_post(
    caption: str = Form(..., min_length=1, max_length=2000),
    category: PostCategory = Form(...),
    location: Optional[str] = Form(default=None, max_length=200),
    images: list[UploadFile] = File(...),
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    file_items = storage_service.read_images(images, field="images", max_files=6)
    image_urls = storage_service.upload_images(file_items, folder="posts")

    result = community_service.create_post(
        db,
        user_id=user_id,
        caption=caption,
        category=category,
        location=location,
        images=image_urls,
    )
    return ok(result)


@router.get("/posts/{post_id}")
def get_post(
    post_id: str,
    user_id: Optional[str] = Depends(optional_user_id),
    db: Session = Depends(get_db),
):
    result = community_service.get_post(db, user_id, post_id)
    return ok(result)


@router.delete("/posts/{post_id}", status_code=204)
def delete_post(
    post_id: str,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    community_service.delete_post(db, user_id, post_id)
    return Response(status_code=204)


@router.post("/posts/{post_id}/like")
def like_post(
    post_id: str,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    result = community_service.like_post(db, user_id, post_id)
    return ok(result)


@router.delete("/posts/{post_id}/like")
def unlike_post(
    post_id: str,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    result = community_service.unlike_post(db, user_id, post_id)
    return ok(result)


@router.post("/posts/{post_id}/bookmark")
def bookmark_post(
    post_id: str,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    result = community_service.bookmark_post(db, user_id, post_id)
    return ok(result)


@router.delete("/posts/{post_id}/bookmark")
def unbookmark_post(
    post_id: str,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    result = community_service.unbookmark_post(db, user_id, post_id)
    return ok(result)


@router.get("/posts/{post_id}/likes")
def list_post_likes(
    post_id: str,
    pg: Pagination = Depends(),
    db: Session = Depends(get_db),
):
    items, total = community_service.list_post_likes(db, post_id, pg.page, pg.limit)
    return paginated(items, page=pg.page, limit=pg.limit, total=total)


@router.get("/posts/{post_id}/comments")
def list_comments(
    post_id: str,
    pg: Pagination = Depends(),
    db: Session = Depends(get_db),
):
    items, total = community_service.list_comments(db, post_id, pg.page, pg.limit)
    return paginated(items, page=pg.page, limit=pg.limit, total=total)


@router.post("/posts/{post_id}/comments", status_code=201)
def add_comment(
    post_id: str,
    body: CommentIn,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    result = community_service.add_comment(db, user_id, post_id, body.text)
    return ok(result)


@router.delete("/comments/{comment_id}", status_code=204)
def delete_comment(
    comment_id: str,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    community_service.delete_comment(db, user_id, comment_id)
    return Response(status_code=204)
