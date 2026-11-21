import re

_EMAIL_RE = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")


def normalize_email(value: str) -> str:
    """الإيميل case-insensitive: بنخزّنه دايماً بحروف صغيرة وبدون مسافات."""
    return value.strip().lower()


def check_email(value: str) -> str:
    email = normalize_email(value)
    if len(email) > 255 or not _EMAIL_RE.match(email):
        raise ValueError("invalid email")
    return email


def check_password(value: str) -> str:
    # 8 حروف على الأقل، فيها حرف ورقم
    if (
        len(value) < 8
        or len(value) > 128
        or not re.search(r"[A-Za-z]", value)
        or not re.search(r"\d", value)
    ):
        raise ValueError("weak password")
    return value


def check_full_name(value: str) -> str:
    name = " ".join(value.split())
    if len(name) < 3 or len(name) > 120:
        raise ValueError("invalid name")
    return name