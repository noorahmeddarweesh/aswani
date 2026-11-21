"""
app/db/models.py
────────────────
SQLAlchemy 2.0 ORM models for Aswani (Sprint 1 + Sprint 2).
Covers all 20 tables:
  1. users
  2. user_preferences
  3. refresh_tokens
  4. password_reset_codes
  5. places
  6. bookmarks
  7. posts
  8. post_likes
  9. post_bookmarks
  10. comments
  11. highlights
  12. culture_themes
  13. stories
  14. story_saves
  15. guides
  16. guide_requests
  17. guide_applications
  18. place_reports
  19. contributions
  20. deletion_requests

All IDs are UUID strings (String(36)) or explicit slugs (places, themes, stories).
Timestamps are UTC DateTime with timezone=True.
"""
from __future__ import annotations

import uuid
from datetime import date as dt_date, datetime, timezone
from typing import Optional

from sqlalchemy import (
    JSON,
    Boolean,
    Date,
    DateTime,
    ForeignKey,
    Index,
    Integer,
    String,
    Text,
    true,
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.session import Base

# JSONB on PostgreSQL for indexing and performance; standard JSON on SQLite for tests
JsonType = JSON().with_variant(JSONB(), "postgresql")


def new_id() -> str:
    """Generate a random UUIDv4 string."""
    return str(uuid.uuid4())


def utcnow() -> datetime:
    """Return timezone-aware current UTC time."""
    return datetime.now(timezone.utc)


# ─── 1. Users ─────────────────────────────────────────────────────────────────

class User(Base):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    full_name: Mapped[str] = mapped_column(String(120), nullable=False)
    identifier: Mapped[str] = mapped_column(String(255), unique=True, index=True, nullable=False)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)

    # Sprint 2 columns
    avatar: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    city: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    bio: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    notifications_enabled: Mapped[bool] = mapped_column(
        Boolean, default=True, server_default=true(), nullable=False
    )

    # Relationships
    preferences: Mapped[Optional["UserPreferences"]] = relationship(
        back_populates="user", uselist=False, cascade="all, delete-orphan"
    )
    refresh_tokens: Mapped[list["RefreshToken"]] = relationship(
        back_populates="user", cascade="all, delete-orphan"
    )
    deletion_request: Mapped[Optional["DeletionRequest"]] = relationship(
        back_populates="user", uselist=False, cascade="all, delete-orphan"
    )


# ─── 2. User Preferences ──────────────────────────────────────────────────────

class UserPreferences(Base):
    __tablename__ = "user_preferences"

    user_id: Mapped[str] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    persona: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    purpose: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    stay_length: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    companions: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    language: Mapped[Optional[str]] = mapped_column(String(5), nullable=True)  # ar | en
    interests: Mapped[list] = mapped_column(JsonType, default=list)
    travel_styles: Mapped[list] = mapped_column(JsonType, default=list)
    needs: Mapped[list] = mapped_column(JsonType, default=list)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=utcnow, onupdate=utcnow
    )

    user: Mapped["User"] = relationship(back_populates="preferences")


# ─── 3. Refresh Tokens ────────────────────────────────────────────────────────

class RefreshToken(Base):
    __tablename__ = "refresh_tokens"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    user_id: Mapped[str] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False
    )
    token_hash: Mapped[str] = mapped_column(String(64), unique=True, index=True, nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    revoked_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)

    user: Mapped["User"] = relationship(back_populates="refresh_tokens")


# ─── 4. Password Reset Codes ──────────────────────────────────────────────────

class PasswordResetCode(Base):
    __tablename__ = "password_reset_codes"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    user_id: Mapped[str] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False
    )
    code_hash: Mapped[str] = mapped_column(String(64), nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    used_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    attempts: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


# ─── 5. Places ────────────────────────────────────────────────────────────────

class Place(Base):
    __tablename__ = "places"

    id: Mapped[str] = mapped_column(String(64), primary_key=True)  # slug: philae, nubian-village
    category: Mapped[str] = mapped_column(String(20), index=True, nullable=False)  # history | nubian | nature | food
    name_en: Mapped[str] = mapped_column(String(200), nullable=False)
    name_ar: Mapped[str] = mapped_column(String(200), nullable=False)
    label_en: Mapped[str] = mapped_column(String(200), default="", server_default="")
    label_ar: Mapped[str] = mapped_column(String(200), default="", server_default="")
    tagline_en: Mapped[str] = mapped_column(String(300), default="", server_default="")
    tagline_ar: Mapped[str] = mapped_column(String(300), default="", server_default="")
    city_en: Mapped[str] = mapped_column(String(100), default="Aswan", server_default="Aswan")
    city_ar: Mapped[str] = mapped_column(String(100), default="أسوان", server_default="أسوان")
    image: Mapped[str] = mapped_column(String(500), default="", server_default="")
    is_curated: Mapped[bool] = mapped_column(Boolean, default=False, server_default="false", index=True)
    is_editors_pick: Mapped[bool] = mapped_column(Boolean, default=False, server_default="false")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)

    # Sprint 2 extended columns
    location_en: Mapped[str] = mapped_column(String(200), default="", server_default="")
    location_ar: Mapped[str] = mapped_column(String(200), default="", server_default="")
    about_en: Mapped[str] = mapped_column(Text, default="", server_default="")
    about_ar: Mapped[str] = mapped_column(Text, default="", server_default="")
    images: Mapped[Optional[list]] = mapped_column(JsonType, default=list)
    facts: Mapped[Optional[list]] = mapped_column(JsonType, default=list)


# ─── 6. Bookmarks ─────────────────────────────────────────────────────────────

class Bookmark(Base):
    __tablename__ = "bookmarks"

    user_id: Mapped[str] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    place_id: Mapped[str] = mapped_column(
        ForeignKey("places.id", ondelete="CASCADE"), primary_key=True
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


# ─── 7. Community: Posts ──────────────────────────────────────────────────────

class Post(Base):
    __tablename__ = "posts"
    __table_args__ = (
        Index("ix_posts_category_created", "category", "created_at"),
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    user_id: Mapped[str] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False
    )
    caption: Mapped[str] = mapped_column(String(2000), nullable=False)
    location: Mapped[Optional[str]] = mapped_column(String(200), nullable=True)
    category: Mapped[str] = mapped_column(String(20), nullable=False)  # local_experience | nubian | nile | food | other
    images: Mapped[list] = mapped_column(JsonType, default=list)
    like_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    comment_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=utcnow, index=True
    )

    author: Mapped["User"] = relationship()


# ─── 8. Community: Post Likes ─────────────────────────────────────────────────

class PostLike(Base):
    __tablename__ = "post_likes"

    user_id: Mapped[str] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    post_id: Mapped[str] = mapped_column(
        ForeignKey("posts.id", ondelete="CASCADE"), primary_key=True
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=utcnow, index=True
    )


# ─── 9. Community: Post Bookmarks ─────────────────────────────────────────────

class PostBookmark(Base):
    __tablename__ = "post_bookmarks"

    user_id: Mapped[str] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    post_id: Mapped[str] = mapped_column(
        ForeignKey("posts.id", ondelete="CASCADE"), primary_key=True
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


# ─── 10. Community: Comments ──────────────────────────────────────────────────

class Comment(Base):
    __tablename__ = "comments"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    post_id: Mapped[str] = mapped_column(
        ForeignKey("posts.id", ondelete="CASCADE"), index=True, nullable=False
    )
    user_id: Mapped[str] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False
    )
    text: Mapped[str] = mapped_column(String(1000), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)

    author: Mapped["User"] = relationship()


# ─── 11. Community: Story Highlights ──────────────────────────────────────────

class Highlight(Base):
    __tablename__ = "highlights"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    title_en: Mapped[str] = mapped_column(String(100), nullable=False)
    title_ar: Mapped[str] = mapped_column(String(100), nullable=False)
    cover_image: Mapped[str] = mapped_column(String(500), default="", server_default="")
    category: Mapped[str] = mapped_column(String(20), nullable=False)
    sort_order: Mapped[int] = mapped_column(Integer, default=0, server_default="0")


# ─── 12. Culture: Themes ──────────────────────────────────────────────────────

class CultureTheme(Base):
    __tablename__ = "culture_themes"

    id: Mapped[str] = mapped_column(String(30), primary_key=True)  # nubian_heritage, ancient_history, etc.
    title_en: Mapped[str] = mapped_column(String(100), nullable=False)
    title_ar: Mapped[str] = mapped_column(String(100), nullable=False)
    image: Mapped[str] = mapped_column(String(500), default="", server_default="")


# ─── 13. Culture: Stories ─────────────────────────────────────────────────────

class Story(Base):
    __tablename__ = "stories"

    id: Mapped[str] = mapped_column(String(64), primary_key=True, default=new_id)
    theme: Mapped[str] = mapped_column(String(30), index=True, nullable=False)
    title_en: Mapped[str] = mapped_column(String(200), nullable=False)
    title_ar: Mapped[str] = mapped_column(String(200), nullable=False)
    label_en: Mapped[str] = mapped_column(String(100), default="", server_default="")
    label_ar: Mapped[str] = mapped_column(String(100), default="", server_default="")
    location_en: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    location_ar: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    cover_image: Mapped[str] = mapped_column(String(500), default="", server_default="")
    read_minutes: Mapped[int] = mapped_column(Integer, default=3, server_default="3")
    is_sample: Mapped[bool] = mapped_column(Boolean, default=True, server_default="true")
    is_featured: Mapped[bool] = mapped_column(Boolean, default=False, server_default="false")
    blocks: Mapped[list] = mapped_column(JsonType, default=list)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=utcnow, index=True
    )


# ─── 14. Culture: Story Saves ─────────────────────────────────────────────────

class StorySave(Base):
    __tablename__ = "story_saves"

    user_id: Mapped[str] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    story_id: Mapped[str] = mapped_column(
        ForeignKey("stories.id", ondelete="CASCADE"), primary_key=True
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


# ─── 15. Local Guides ─────────────────────────────────────────────────────────

class Guide(Base):
    __tablename__ = "guides"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    user_id: Mapped[Optional[str]] = mapped_column(
        ForeignKey("users.id", ondelete="SET NULL"), nullable=True
    )
    full_name: Mapped[str] = mapped_column(String(120), nullable=False)
    photo: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    city: Mapped[str] = mapped_column(String(100), default="Aswan", server_default="Aswan")
    tagline: Mapped[str] = mapped_column(String(200), default="", server_default="")
    languages: Mapped[list] = mapped_column(JsonType, default=list)
    specialties: Mapped[list] = mapped_column(JsonType, default=list)
    durations: Mapped[list] = mapped_column(JsonType, default=list)
    bio: Mapped[str] = mapped_column(Text, default="", server_default="")
    is_featured: Mapped[bool] = mapped_column(Boolean, default=False, server_default="false")
    is_verified: Mapped[bool] = mapped_column(Boolean, default=False, server_default="false")


# ─── 16. Guide Requests ───────────────────────────────────────────────────────

class GuideRequest(Base):
    __tablename__ = "guide_requests"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    user_id: Mapped[str] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False
    )
    guide_id: Mapped[str] = mapped_column(
        ForeignKey("guides.id", ondelete="CASCADE"), index=True, nullable=False
    )
    date: Mapped[dt_date] = mapped_column(Date, nullable=False)
    duration: Mapped[str] = mapped_column(String(20), nullable=False)
    duration_hours: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    start_time: Mapped[str] = mapped_column(String(5), nullable=False)  # HH:mm
    group_size: Mapped[int] = mapped_column(Integer, nullable=False)
    language: Mapped[str] = mapped_column(String(5), nullable=False)
    interests: Mapped[list] = mapped_column(JsonType, default=list)
    notes: Mapped[Optional[str]] = mapped_column(String(1000), nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="pending", server_default="pending")
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=utcnow, index=True
    )

    guide: Mapped["Guide"] = relationship()


# ─── 17. Guide Applications ───────────────────────────────────────────────────

class GuideApplication(Base):
    __tablename__ = "guide_applications"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    user_id: Mapped[str] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False
    )
    full_name: Mapped[str] = mapped_column(String(120), nullable=False)
    languages: Mapped[list] = mapped_column(JsonType, default=list)
    specialties: Mapped[list] = mapped_column(JsonType, default=list)
    durations: Mapped[list] = mapped_column(JsonType, default=list)
    bio: Mapped[str] = mapped_column(Text, default="", server_default="")
    contact: Mapped[str] = mapped_column(String(20), nullable=False)
    profile_photo: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="pending", server_default="pending")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


# ─── 18. Place Reports ────────────────────────────────────────────────────────

class PlaceReport(Base):
    __tablename__ = "place_reports"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    user_id: Mapped[str] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False
    )
    place_id: Mapped[str] = mapped_column(
        ForeignKey("places.id", ondelete="CASCADE"), index=True, nullable=False
    )
    reason: Mapped[str] = mapped_column(String(30), nullable=False)
    details: Mapped[str] = mapped_column(String(1000), nullable=False)
    photo: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="pending", server_default="pending")
    points_awarded: Mapped[int] = mapped_column(Integer, default=0, server_default="0")
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=utcnow, index=True
    )

    place: Mapped["Place"] = relationship()


# ─── 19. Contributions ────────────────────────────────────────────────────────

class Contribution(Base):
    __tablename__ = "contributions"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    user_id: Mapped[str] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False
    )
    category: Mapped[str] = mapped_column(String(20), nullable=False)
    name: Mapped[str] = mapped_column(String(200), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    address: Mapped[str] = mapped_column(String(300), nullable=False)
    contact_number: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    photos: Mapped[list] = mapped_column(JsonType, default=list)
    status: Mapped[str] = mapped_column(String(20), default="pending", server_default="pending")
    points_awarded: Mapped[int] = mapped_column(Integer, default=0, server_default="0")
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=utcnow, index=True
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=utcnow, onupdate=utcnow
    )


# ─── 20. Deletion Requests ────────────────────────────────────────────────────

class DeletionRequest(Base):
    __tablename__ = "deletion_requests"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    user_id: Mapped[str] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False
    )
    status: Mapped[str] = mapped_column(String(20), default="requested", server_default="requested")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)

    user: Mapped["User"] = relationship(back_populates="deletion_request")
