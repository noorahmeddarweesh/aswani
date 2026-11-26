"""
app/db/session.py
─────────────────
SQLAlchemy engine and session factory.

Connection pool settings are tuned for Supabase's Session Pooler
(port 5432) on Render:
  • pool_pre_ping=True  — Checks the connection before each use; silently
                          reconnects when Supabase terminates idle sockets.
  • pool_recycle=1800   — Recycle connections every 30 minutes.
  • pool_size=5         — Render's free tier is single-instance; 5 is plenty.
  • max_overflow=5      — Allow up to 10 total connections under burst traffic.

We use synchronous psycopg2 (not asyncpg) because:
  1. FastAPI's thread-pool dispatch makes sync routes non-blocking.
  2. Async SQLAlchemy with Supabase's pooler has known connection-leak issues.
"""
from __future__ import annotations

from sqlalchemy import create_engine, event, text
from sqlalchemy.orm import DeclarativeBase, sessionmaker

from app.core.config import settings

# ── Engine ────────────────────────────────────────────────────────────────────
_connect_args: dict = {}
if settings.DATABASE_URL.startswith("sqlite"):
    # SQLite in tests: enable WAL mode and foreign keys
    _connect_args = {"check_same_thread": False}

engine = create_engine(
    settings.DATABASE_URL,
    pool_pre_ping=True,
    pool_recycle=1800,
    # SQLite doesn't support pool_size / max_overflow
    **(
        {"pool_size": 5, "max_overflow": 5}
        if not settings.DATABASE_URL.startswith("sqlite")
        else {}
    ),
    connect_args=_connect_args,
    echo=settings.APP_DEBUG,     # logs every SQL statement in development
)

# Enable foreign-key enforcement for SQLite (used in tests)
if settings.DATABASE_URL.startswith("sqlite"):
    @event.listens_for(engine, "connect")
    def _set_sqlite_pragma(dbapi_conn, _):
        cursor = dbapi_conn.cursor()
        cursor.execute("PRAGMA foreign_keys=ON")
        cursor.close()

# ── Session factory ───────────────────────────────────────────────────────────
SessionLocal = sessionmaker(
    bind=engine,
    autocommit=False,
    autoflush=False,
    expire_on_commit=False,   # prevents "DetachedInstanceError" after commit
)


# ── Declarative base ──────────────────────────────────────────────────────────
class Base(DeclarativeBase):
    """
    Shared base for all SQLAlchemy models.

    Import and subclass this in app/db/models.py:
        from app.db.session import Base
        class User(Base): ...
    """
    pass
