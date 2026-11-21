import logging
import smtplib
from email.message import EmailMessage

from app.core.config import settings

log = logging.getLogger("aswani")


def send_reset_code(to_email: str, code: str) -> None:
    # لو مفيش إعدادات إيميل في التطوير: اطبعي الكود في الـ terminal عشان تجرّبي
    if not settings.smtp_host or not settings.smtp_user:
        if not settings.is_production:
            log.warning("[DEV] reset code for %s: %s", to_email, code)
        return

    msg = EmailMessage()
    msg["Subject"] = "Aswani - your password reset code"
    msg["From"] = settings.smtp_from or settings.smtp_user
    msg["To"] = to_email
    msg.set_content(
        f"Your Aswani reset code is: {code}\n"
        f"It expires in {settings.reset_code_minutes} minutes.\n"
        "If you did not request it, ignore this email."
    )
    try:
        with smtplib.SMTP(settings.smtp_host, settings.smtp_port, timeout=10) as server:
            server.starttls()
            server.login(settings.smtp_user, settings.smtp_password)
            server.send_message(msg)
    except Exception:
        log.exception("Failed to send reset email")