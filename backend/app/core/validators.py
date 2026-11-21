"""
app/core/validators.py
──────────────────────
Pure validation helpers shared across all services.

Nothing here depends on the database or HTTP layer — only standard-library
and stdlib-compatible operations.  Every function raises ValueError with
a machine-readable code string so services can convert it into an AppError.
"""
from __future__ import annotations

import re


# ─── Email ────────────────────────────────────────────────────────────────────

_EMAIL_RE = re.compile(
    r"^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$",
    re.ASCII,
)


def normalize_email(raw: str) -> str:
    """
    Lowercase, strip whitespace, and validate the format.

    Raises:
        ValueError("INVALID_EMAIL") – when the format is wrong.
    """
    email = raw.strip().lower()
    if not email or not _EMAIL_RE.match(email):
        raise ValueError("INVALID_EMAIL")
    return email


# ─── Password ─────────────────────────────────────────────────────────────────

def validate_password(password: str) -> str:
    """
    Enforce contract password rules (contract v0.1):
      • 8–128 characters
      • at least one uppercase letter
      • at least one lowercase letter
      • at least one digit

    Returns the password unchanged when valid.

    Raises:
        ValueError("WEAK_PASSWORD") – when any rule is violated.
    """
    if not (8 <= len(password) <= 128):
        raise ValueError("WEAK_PASSWORD")
    if not any(c.isupper() for c in password):
        raise ValueError("WEAK_PASSWORD")
    if not any(c.islower() for c in password):
        raise ValueError("WEAK_PASSWORD")
    if not any(c.isdigit() for c in password):
        raise ValueError("WEAK_PASSWORD")
    return password


# ─── Full name ────────────────────────────────────────────────────────────────

def normalize_full_name(raw: str) -> str:
    """
    Strip and collapse internal whitespace.

    Raises:
        ValueError("INVALID_NAME") – when empty after stripping.
    """
    name = " ".join(raw.split())
    if not name:
        raise ValueError("INVALID_NAME")
    if len(name) > 100:
        raise ValueError("INVALID_NAME")
    return name


# ─── Egyptian mobile number ───────────────────────────────────────────────────

# Accepts: +201XXXXXXXXX  |  00201XXXXXXXXX  |  01XXXXXXXXX  |  1XXXXXXXXX
# Valid networks: 010 (Vodafone), 011 (Etisalat/WE), 012 (Orange), 015 (WE)
_EGY_PHONE_RE = re.compile(r"^(?:\+20|0020|0)?1[0125]\d{8}$")


def normalize_phone(raw: str) -> str:
    """
    Strip whitespace/dashes, validate as an Egyptian mobile number, and
    return the international E.164 form (+201XXXXXXXXX).

    Raises:
        ValueError("INVALID_PHONE") – when the number is not an Egyptian mobile.
    """
    cleaned = re.sub(r"[\s\-]", "", raw)
    if not _EGY_PHONE_RE.match(cleaned):
        raise ValueError("INVALID_PHONE")
    # Normalise to +20 form
    if cleaned.startswith("00"):
        cleaned = "+" + cleaned[2:]
    elif cleaned.startswith("0"):
        cleaned = "+20" + cleaned[1:]
    elif cleaned.startswith("1"):
        cleaned = "+20" + cleaned
    # Already +20...
    return cleaned


# ─── Pagination ───────────────────────────────────────────────────────────────

def clamp_page(page: int | None, limit: int | None) -> tuple[int, int]:
    """
    Sanitise *page* and *limit* query parameters.

    Returns:
        (page, limit) – both clamped to safe ranges.
    """
    p = max(1, page or 1)
    lim = min(100, max(1, limit or 20))
    return p, lim
