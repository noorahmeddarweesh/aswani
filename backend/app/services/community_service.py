"""
app/services/community_service.py
─────────────────────────────────
Business logic for Community feed, posts, likes, bookmarks, comments,
and story highlights.
"""
from __future__ import annotations

from datetime import timedelta
from typing import Optional
from sqlalchemy import func, select, update
from sqlalchemy.orm import Session, joinedload

from app.core.errors import AppError
from app.core.security import utcnow
from app.db.models import (
    Comment,
    Highlight,
    Post,
    PostBookmark,
    PostLike,
    User,
)


def highlight_to_dict(h: Highlight) -> dict:
    return {
        "id": h.id,
        "title_en": h.title_en,
        "title_ar": h.title_ar,
        "cover_image": h.cover_image,
        "category": h.category,
    }


def post_to_dict(p: Post, is_liked: bool = False, is_bookmarked: bool = False) -> dict:
    author = p.author
    return {
        "id": p.id,
        "author": {
            "id": author.id if author else p.user_id,
            "full_name": author.full_name if author else "",
            "avatar": author.avatar if author else None,
        },
        "images": p.images or [],
        "caption": p.caption,
        "location": p.location,
        "category": p.category,
        "like_count": p.like_count,
        "comment_count": p.comment_count,
        "is_liked": is_liked,
        "is_bookmarked": is_bookmarked,
        "created_at": p.created_at.isoformat() if p.created_at else None,
    }


def get_highlights(db: Session) -> list[dict]:
    highlights = db.scalars(
        select(Highlight).order_by(Highlight.sort_order.asc()).limit(10)
    ).all()
    return [highlight_to_dict(h) for h in highlights]


def _liked_post_ids(db: Session, user_id: Optional[str], post_ids: list[str]) -> set[str]:
    if not user_id or not post_ids:
        return set()
    return set(
        db.scalars(
            select(PostLike.post_id).where(
                PostLike.user_id == user_id, PostLike.post_id.in_(post_ids)
            )
        ).all()
    )


def _bookmarked_post_ids(db: Session, user_id: Optional[str], post_ids: list[str]) -> set[str]:
    if not user_id or not post_ids:
        return set()
    return set(
        db.scalars(
            select(PostBookmark.post_id).where(
                PostBookmark.user_id == user_id, PostBookmark.post_id.in_(post_ids)
            )
        ).all()
    )


def list_posts(
    db: Session,
    user_id: Optional[str],
    category: Optional[str],
    sort: Optional[str],
    page: int,
    limit: int,
) -> tuple[list[dict], int]:
    stmt = select(Post).options(joinedload(Post.author))
    count_stmt = select(func.count(Post.id))

    if category:
        stmt = stmt.where(Post.category == category)
        count_stmt = count_stmt.where(Post.category == category)

    total = db.scalar(count_stmt) or 0

    if sort == "top":
        seven_days_ago = utcnow() - timedelta(days=7)
        # Left outer join with recent likes to sort by popularity
        recent_likes = (
            select(
                PostLike.post_id,
                func.count(PostLike.user_id).label("recent_count"),
            )
            .where(PostLike.created_at >= seven_days_ago)
            .group_by(PostLike.post_id)
            .subquery()
        )
        stmt = (
            stmt.outerjoin(recent_likes, Post.id == recent_likes.c.post_id)
            .order_by(
                func.coalesce(recent_likes.c.recent_count, 0).desc(),
                Post.created_at.desc(),
            )
        )
    else:
        stmt = stmt.order_by(Post.created_at.desc())

    posts = db.scalars(
        stmt.offset((page - 1) * limit).limit(limit)
    ).unique().all()

    post_ids = [p.id for p in posts]
    liked_ids = _liked_post_ids(db, user_id, post_ids)
    bookmarked_ids = _bookmarked_post_ids(db, user_id, post_ids)

    items = [
        post_to_dict(p, p.id in liked_ids, p.id in bookmarked_ids)
        for p in posts
    ]
    return items, total


def create_post(
    db: Session,
    user_id: str,
    caption: str,
    category: str,
    location: Optional[str],
    images: list[str],
) -> dict:
    if not images:
        raise AppError(422, "VALIDATION_ERROR", "At least one image is required.", {"images": "REQUIRED"})

    user = db.get(User, user_id)
    post = Post(
        user_id=user_id,
        caption=caption.strip(),
        category=category,
        location=location.strip() if location else None,
        images=images,
        like_count=0,
        comment_count=0,
    )
    db.add(post)
    db.commit()
    db.refresh(post)

    return post_to_dict(post, is_liked=False, is_bookmarked=False)


def get_post(db: Session, user_id: Optional[str], post_id: str) -> dict:
    post = db.scalar(
        select(Post).options(joinedload(Post.author)).where(Post.id == post_id)
    )
    if not post:
        raise AppError(404, "POST_NOT_FOUND", "Post not found.")

    liked_ids = _liked_post_ids(db, user_id, [post.id])
    bookmarked_ids = _bookmarked_post_ids(db, user_id, [post.id])
    return post_to_dict(post, post.id in liked_ids, post.id in bookmarked_ids)


def delete_post(db: Session, user_id: str, post_id: str) -> None:
    post = db.get(Post, post_id)
    if not post:
        raise AppError(404, "POST_NOT_FOUND", "Post not found.")

    if post.user_id != user_id:
        raise AppError(403, "FORBIDDEN", "You can only delete your own posts.")

    db.delete(post)
    db.commit()


def like_post(db: Session, user_id: str, post_id: str) -> dict:
    post = db.get(Post, post_id)
    if not post:
        raise AppError(404, "POST_NOT_FOUND", "Post not found.")

    existing = db.get(PostLike, (user_id, post_id))
    if not existing:
        db.add(PostLike(user_id=user_id, post_id=post_id))
        db.execute(
            update(Post).where(Post.id == post_id).values(like_count=Post.like_count + 1)
        )
        db.commit()
        db.refresh(post)

    return {"like_count": post.like_count, "is_liked": True}


def unlike_post(db: Session, user_id: str, post_id: str) -> dict:
    post = db.get(Post, post_id)
    if not post:
        raise AppError(404, "POST_NOT_FOUND", "Post not found.")

    existing = db.get(PostLike, (user_id, post_id))
    if existing:
        db.delete(existing)
        new_count = max(0, post.like_count - 1)
        db.execute(
            update(Post).where(Post.id == post_id).values(like_count=new_count)
        )
        db.commit()
        db.refresh(post)

    return {"like_count": post.like_count, "is_liked": False}


def bookmark_post(db: Session, user_id: str, post_id: str) -> dict:
    post = db.get(Post, post_id)
    if not post:
        raise AppError(404, "POST_NOT_FOUND", "Post not found.")

    existing = db.get(PostBookmark, (user_id, post_id))
    if not existing:
        db.add(PostBookmark(user_id=user_id, post_id=post_id))
        db.commit()

    return {"is_bookmarked": True}


def unbookmark_post(db: Session, user_id: str, post_id: str) -> dict:
    post = db.get(Post, post_id)
    if not post:
        raise AppError(404, "POST_NOT_FOUND", "Post not found.")

    existing = db.get(PostBookmark, (user_id, post_id))
    if existing:
        db.delete(existing)
        db.commit()

    return {"is_bookmarked": False}


def list_post_likes(
    db: Session, post_id: str, page: int, limit: int
) -> tuple[list[dict], int]:
    post = db.get(Post, post_id)
    if not post:
        raise AppError(404, "POST_NOT_FOUND", "Post not found.")

    stmt = (
        select(User)
        .join(PostLike, PostLike.user_id == User.id)
        .where(PostLike.post_id == post_id)
        .order_by(PostLike.created_at.desc())
    )
    total = db.scalar(
        select(func.count(PostLike.user_id)).where(PostLike.post_id == post_id)
    ) or 0
    users = db.scalars(stmt.offset((page - 1) * limit).limit(limit)).all()

    items = [
        {"id": u.id, "full_name": u.full_name, "avatar": u.avatar}
        for u in users
    ]
    return items, total


def list_comments(
    db: Session, post_id: str, page: int, limit: int
) -> tuple[list[dict], int]:
    post = db.get(Post, post_id)
    if not post:
        raise AppError(404, "POST_NOT_FOUND", "Post not found.")

    stmt = (
        select(Comment)
        .options(joinedload(Comment.author))
        .where(Comment.post_id == post_id)
        .order_by(Comment.created_at.asc())  # oldest first
    )
    total = db.scalar(
        select(func.count(Comment.id)).where(Comment.post_id == post_id)
    ) or 0
    comments = db.scalars(stmt.offset((page - 1) * limit).limit(limit)).all()

    items = []
    for c in comments:
        a = c.author
        items.append({
            "id": c.id,
            "author": {
                "id": a.id if a else c.user_id,
                "full_name": a.full_name if a else "",
                "avatar": a.avatar if a else None,
            },
            "text": c.text,
            "created_at": c.created_at.isoformat() if c.created_at else None,
        })
    return items, total


def add_comment(db: Session, user_id: str, post_id: str, text: str) -> dict:
    post = db.get(Post, post_id)
    if not post:
        raise AppError(404, "POST_NOT_FOUND", "Post not found.")

    clean_text = text.strip()
    if not clean_text:
        raise AppError(422, "VALIDATION_ERROR", "Comment text cannot be empty.", {"text": "REQUIRED"})

    user = db.get(User, user_id)
    comment = Comment(post_id=post_id, user_id=user_id, text=clean_text)
    db.add(comment)
    db.execute(
        update(Post).where(Post.id == post_id).values(comment_count=Post.comment_count + 1)
    )
    db.commit()
    db.refresh(comment)

    return {
        "id": comment.id,
        "author": {
            "id": user.id if user else user_id,
            "full_name": user.full_name if user else "",
            "avatar": user.avatar if user else None,
        },
        "text": comment.text,
        "created_at": comment.created_at.isoformat() if comment.created_at else None,
    }


def delete_comment(db: Session, user_id: str, comment_id: str) -> None:
    comment = db.get(Comment, comment_id)
    if not comment:
        raise AppError(404, "COMMENT_NOT_FOUND", "Comment not found.")

    if comment.user_id != user_id:
        raise AppError(403, "FORBIDDEN", "You can only delete your own comments.")

    post_id = comment.post_id
    db.delete(comment)
    post = db.get(Post, post_id)
    if post:
        new_count = max(0, post.comment_count - 1)
        db.execute(
            update(Post).where(Post.id == post_id).values(comment_count=new_count)
        )
    db.commit()
