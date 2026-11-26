"""
app/core/config.py
──────────────────
Centralised settings loaded from the environment (or a .env file).
Every module imports from here — never from os.environ directly.

Pydantic-Settings reads .env automatically when a file named ".env"
exists in the working directory (backend/).
"""
from __future__ import annotations

from functools import lru_cache

from pydantic import AnyHttpUrl, field_validator, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """All environment variables Aswani backend needs."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",           # silently ignore unknown vars in .env
    )

    # ── App ───────────────────────────────────────────────────────────────────
    APP_ENV: str = "development"
    APP_DEBUG: bool = False
    APP_SECRET_KEY: str = "change-me"

    # ── JWT ───────────────────────────────────────────────────────────────────
    JWT_SECRET_KEY: str = "change-me-jwt-secret"
    JWT_ALGORITHM: str = "HS256"
    JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    JWT_REFRESH_TOKEN_EXPIRE_DAYS: int = 30

    # ── Database ──────────────────────────────────────────────────────────────
    DATABASE_URL: str = "sqlite:///./aswani_dev.db"   # safe fallback for tests

    # ── Supabase Storage ──────────────────────────────────────────────────────
    SUPABASE_URL: str = ""
    SUPABASE_SERVICE_ROLE_KEY: str = ""
    SUPABASE_STORAGE_BUCKET: str = "images"

    # ── Password Reset ────────────────────────────────────────────────────────
    RESET_CODE_SECRET: str = "change-me-reset-hmac"
    RESET_CODE_EXPIRE_MINUTES: int = 10
    RESET_CODE_MAX_ATTEMPTS: int = 5

    # ── Email (SMTP) ──────────────────────────────────────────────────────────
    SMTP_HOST: str = "localhost"
    SMTP_PORT: int = 587
    SMTP_USER: str = ""
    SMTP_PASSWORD: str = ""
    EMAIL_FROM: str = "noreply@aswani.app"

    # ── CORS ──────────────────────────────────────────────────────────────────
    CORS_ORIGINS: str = "*"           # comma-separated in .env

    # ── Seed account (matches mobile mock data) ───────────────────────────────
    SEED_DEMO_EMAIL: str = "laila@example.com"
    SEED_DEMO_PASSWORD: str = "Aswan2026"
    SEED_DEMO_FULL_NAME: str = "Laila Hassan"

    # ── Computed helpers ──────────────────────────────────────────────────────
    @property
    def is_production(self) -> bool:
        return self.APP_ENV.lower() == "production"

    @property
    def is_development(self) -> bool:
        return self.APP_ENV.lower() == "development"

    @property
    def cors_origins_list(self) -> list[str]:
        """Return CORS_ORIGINS as a Python list."""
        raw = self.CORS_ORIGINS.strip()
        if raw == "*":
            return ["*"]
        return [o.strip() for o in raw.split(",") if o.strip()]

    @field_validator("DATABASE_URL", mode="before")
    @classmethod
    def _reject_empty_db(cls, v: str) -> str:
        if not v:
            raise ValueError("DATABASE_URL must be set")
        return v


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """Return the global Settings singleton (cached after first call)."""
    return Settings()


# Module-level alias so other modules can do:
#   from app.core.config import settings
settings: Settings = get_settings()
