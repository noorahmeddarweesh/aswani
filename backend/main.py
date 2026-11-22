"""
main.py
───────
FastAPI application factory for Aswani.

This module is the entry point:
  uvicorn main:app --reload              (local development)
  uvicorn main:app --host 0.0.0.0 --port 8000 --proxy-headers  (Render)

Responsibilities:
  • Creates the FastAPI app instance with metadata.
  • Registers CORS, rate-limiter middleware.
  • Attaches contract-compliant error handlers.
  • Mounts all API routers under the /api prefix.
  • Exposes GET /api/health for Render's health checks.
"""
from __future__ import annotations

import logging

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware

from app.core.config import settings
from app.core.errors import AppError, register_error_handlers
from app.core.limiter import limiter
from app.core.responses import ok

# ─── Logging ─────────────────────────────────────────────────────────────────
logging.basicConfig(
    level=logging.DEBUG if settings.APP_DEBUG else logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(name)s — %(message)s",
)
logger = logging.getLogger(__name__)

# ─── App factory ─────────────────────────────────────────────────────────────

def create_app() -> FastAPI:
    app = FastAPI(
        title="Aswani API",
        version="0.3.0",
        summary="Smart mobile guide to Aswan, Egypt — backend API.",
        description=(
            "Implements the Aswani mobile app contract (v0.1–v0.3). "
            "All endpoints live under /api. "
            "Authorization: Bearer <access_token> on every protected route."
        ),
        docs_url="/api/docs" if not settings.is_production else None,
        redoc_url="/api/redoc" if not settings.is_production else None,
        openapi_url="/api/openapi.json" if not settings.is_production else None,
        debug=settings.APP_DEBUG,
    )

    # ── Rate limiter ──────────────────────────────────────────────────────────
    app.state.limiter = limiter
    app.add_middleware(SlowAPIMiddleware)
    app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

    # ── CORS ──────────────────────────────────────────────────────────────────
    app.add_middleware(
        CORSMiddleware,
        allow_origin_regex=r"^https?://.*$",
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    app.add_middleware(GZipMiddleware, minimum_size=1000)

    # ── Contract error handlers ───────────────────────────────────────────────
    register_error_handlers(app)

    # ── Routers ───────────────────────────────────────────────────────────────
    from app.routers import (
        auth,
        bookmarks,
        community,
        contributions,
        culture,
        guides,
        places,
        profile,
        reports,
        users,
    )

    all_routers = [
        auth.router,
        users.router,
        places.router,
        bookmarks.router,
        guides.router,
        reports.router,
        community.router,
        culture.router,
        contributions.router,
        profile.router,
    ]
    for r in all_routers:
        app.include_router(r, prefix="/api")
        app.include_router(r)

    # ── Health check ──────────────────────────────────────────────────────────
    @app.get("/health", tags=["System"])
    @app.get("/api/health", tags=["System"], summary="Health check for Render")
    def health(request: Request) -> dict:
        return ok({"status": "ok", "version": app.version, "env": settings.APP_ENV})

    logger.info("Aswani API v%s started (env=%s)", app.version, settings.APP_ENV)
    return app


app = create_app()
