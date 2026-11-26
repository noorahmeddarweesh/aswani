"""
app/services/storage_service.py
───────────────────────────────
Supabase Storage file upload service.
Follows API Contract v0.2 / v0.3 "Photo uploads":
  • multipart/form-data
  • max 6 files per request (TOO_MANY_PHOTOS)
  • max 5 MB per file (FILE_TOO_LARGE)
  • allowed types: jpg, png, webp (UNSUPPORTED_FILE_TYPE)
  • MIME is sniffed from the first magic bytes, never trusted from client
  • Returns full public URL:
    {SUPABASE_URL}/storage/v1/object/public/{STORAGE_BUCKET}/{path}
"""
from __future__ import annotations

import logging
import uuid
from typing import Optional

import httpx
from fastapi import UploadFile

from app.core.config import settings
from app.core.errors import AppError

logger = logging.getLogger(__name__)

MAX_BYTES = 5 * 1024 * 1024  # 5 MB
MAX_FILES = 6
EXT_MAP = {
    "image/jpeg": "jpg",
    "image/png": "png",
    "image/webp": "webp",
}


def sniff_mime(data: bytes) -> Optional[str]:
    """Inspect magic bytes to determine true image MIME type."""
    if data.startswith(b"\xff\xd8\xff"):
        return "image/jpeg"
    if data.startswith(b"\x89PNG\r\n\x1a\n"):
        return "image/png"
    if len(data) >= 12 and data[:4] == b"RIFF" and data[8:12] == b"WEBP":
        return "image/webp"
    return None


def read_images(
    files: Optional[list[UploadFile]],
    field: str = "images",
    max_files: int = MAX_FILES,
) -> list[tuple[bytes, str]]:
    """
    Validate and read all images into memory.
    If ANY single file fails, no files are uploaded and AppError is raised.
    """
    valid_files = [f for f in (files or []) if f and f.filename]
    if len(valid_files) > max_files:
        raise AppError(422, "TOO_MANY_PHOTOS", "Too many photos uploaded.")

    items: list[tuple[bytes, str]] = []
    for f in valid_files:
        data = f.file.read(MAX_BYTES + 1)
        if len(data) > MAX_BYTES:
            raise AppError(
                422,
                "VALIDATION_ERROR",
                "File too large",
                {field: "FILE_TOO_LARGE"},
            )
        mime = sniff_mime(data)
        if mime is None:
            raise AppError(
                422,
                "VALIDATION_ERROR",
                "Unsupported file type",
                {field: "UNSUPPORTED_FILE_TYPE"},
            )
        items.append((data, mime))
    return items


def _upload_one(data: bytes, mime: str, folder: str) -> str:
    """Upload a single image buffer to Supabase Storage and return its public URL."""
    filename = f"{uuid.uuid4().hex}.{EXT_MAP[mime]}"
    path = f"{folder}/{filename}"

    # If Supabase is not configured (e.g. local dev / tests without Supabase),
    # return a mock public URL to allow end-to-end testing without throwing errors.
    if not settings.SUPABASE_URL or not settings.SUPABASE_SERVICE_ROLE_KEY:
        logger.warning(
            "Supabase Storage credentials not configured. Returning local mock URL for %s",
            path,
        )
        return f"http://localhost:8000/storage/mock/{path}"

    url = f"{settings.SUPABASE_URL}/storage/v1/object/{settings.SUPABASE_STORAGE_BUCKET}/{path}"
    headers = {
        "Authorization": f"Bearer {settings.SUPABASE_SERVICE_ROLE_KEY}",
        "apikey": settings.SUPABASE_SERVICE_ROLE_KEY,
        "Content-Type": mime,
    }

    try:
        resp = httpx.post(url, content=data, headers=headers, timeout=20.0)
        resp.raise_for_status()
    except httpx.HTTPError as exc:
        logger.error("Supabase Storage upload failed for path %s: %s", path, exc)
        raise AppError(500, "SERVER_ERROR", "Failed to upload image to storage.")

    return f"{settings.SUPABASE_URL}/storage/v1/object/public/{settings.SUPABASE_STORAGE_BUCKET}/{path}"


def upload_images(items: list[tuple[bytes, str]], folder: str) -> list[str]:
    """Upload multiple validated images and return full public URLs."""
    return [_upload_one(data, mime, folder) for data, mime in items]
