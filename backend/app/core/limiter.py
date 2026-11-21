"""
app/core/limiter.py
───────────────────
Global rate-limiter instance (SlowAPI / limits).

SlowAPI wraps `limits` and integrates with FastAPI via a middleware +
exception handler approach.  We configure one shared `Limiter` instance
here and import it everywhere.

Default strategy:
  • Key = client IP address (X-Forwarded-For when behind Render's proxy)
  • Storage = in-memory (dev) — replace with Redis URL for multi-instance prod

Sensitive auth routes are decorated with stricter limits in routers/auth.py:
  • POST /auth/login          → 10 / minute
  • POST /auth/forgot-password→  5 / minute
  • POST /auth/register       → 10 / minute

All other routes fall back to the global default: 120 / minute.

Usage in a router:
    from app.core.limiter import limiter
    @router.post("/login")
    @limiter.limit("10/minute")
    async def login(request: Request, ...):
        ...
"""
from __future__ import annotations

from slowapi import Limiter
from slowapi.util import get_remote_address

# ---------------------------------------------------------------------------
# Single module-level instance – imported by main.py and routers
# ---------------------------------------------------------------------------
limiter = Limiter(
    key_func=get_remote_address,
    # In production set this to your Redis URL:
    #   storage_uri="redis://localhost:6379/0"
    # For development, the default in-memory backend is fine.
    default_limits=["120/minute"],
    headers_enabled=True,     # adds X-RateLimit-* headers to every response
)
