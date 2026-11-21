"""
app/services/email_service.py
─────────────────────────────
Email dispatch service for password reset codes and system notifications.
"""
from __future__ import annotations

import logging
import smtplib
from email.message import EmailMessage

from app.core.config import settings

logger = logging.getLogger(__name__)


def send_reset_code(to_email: str, code: str) -> None:
    """Send 4-digit reset code via SMTP, or log to console in development."""
    if not settings.SMTP_HOST or settings.SMTP_HOST == "localhost" or not settings.SMTP_USER:
        if not settings.is_production:
            logger.info("==================================================")
            logger.info("[DEV] Password reset code for %s: %s", to_email, code)
            logger.info("==================================================")
        return

    msg = EmailMessage()
    msg["Subject"] = "Aswani — Your password reset code"
    msg["From"] = settings.EMAIL_FROM or settings.SMTP_USER
    msg["To"] = to_email
    msg.set_content(
        f"Your Aswani reset code is: {code}\n\n"
        f"This code will expire in {settings.RESET_CODE_EXPIRE_MINUTES} minutes.\n"
        "If you did not request this reset code, please ignore this email."
    )

    try:
        with smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT, timeout=10.0) as server:
            server.starttls()
            server.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
            server.send_message(msg)
    except Exception as exc:
        logger.error("Failed to send reset email to %s: %s", to_email, exc)
