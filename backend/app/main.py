from fastapi import APIRouter, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.responses import JSONResponse
from sqlalchemy import text

from app.core.config import settings
from app.core.errors import register_error_handlers
from app.core.limiter import limiter
from app.db.session import engine
from app.routers import auth, users

app = FastAPI(
    title="Aswani API",
    version="1.0.0",
    docs_url=None if settings.is_production else "/docs",
    openapi_url=None if settings.is_production else "/openapi.json",
    redoc_url=None,
)
app.state.limiter = limiter
register_error_handlers(app)

app.add_middleware(GZipMiddleware, minimum_size=1000)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_list,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def security_headers(request, call_next):
    response = await call_next(request)
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["Referrer-Policy"] = "no-referrer"
    return response


api = APIRouter(prefix="/api")
# هنضيف الـ routers هنا في الـ Tasks الجاية:
# api.include_router(auth.router)
api.include_router(auth.router)
api.include_router(users.router)
app.include_router(api)


@app.get("/health", include_in_schema=False)
def health():
    """Render بيستخدمه عشان يتأكد إن السيرفر شغال."""
    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
    except Exception:
        return JSONResponse({"status": "db_down"}, status_code=503)
    return {"status": "ok"}