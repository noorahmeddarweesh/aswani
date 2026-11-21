import logging

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from slowapi.errors import RateLimitExceeded
from starlette.exceptions import HTTPException as StarletteHTTPException

log = logging.getLogger("aswani")


class AppError(Exception):
    """ارفعها من أي مكان: raise AppError(404, "PLACE_NOT_FOUND")"""

    def __init__(self, status_code: int, code: str, message: str = "", details: dict | None = None):
        self.status_code = status_code
        self.code = code
        self.message = message or code
        self.details = details or {}


def error_body(code: str, message: str, details: dict | None = None) -> dict:
    return {"error": {"code": code, "message": message, "details": details or {}}}


def register_error_handlers(app: FastAPI) -> None:
    @app.exception_handler(AppError)
    async def _app_error(request: Request, exc: AppError):
        return JSONResponse(error_body(exc.code, exc.message, exc.details), status_code=exc.status_code)

    @app.exception_handler(RequestValidationError)
    async def _validation(request: Request, exc: RequestValidationError):
        details: dict[str, str] = {}
        for err in exc.errors():
            loc = [str(p) for p in err["loc"]]
            field = loc[1] if len(loc) > 1 else loc[0]
            details.setdefault(field, "INVALID")
        return JSONResponse(error_body("VALIDATION_ERROR", "Invalid request", details), status_code=422)

    @app.exception_handler(StarletteHTTPException)
    async def _http(request: Request, exc: StarletteHTTPException):
        codes = {404: "NOT_FOUND", 405: "METHOD_NOT_ALLOWED"}
        default = "SERVER_ERROR" if exc.status_code >= 500 else "BAD_REQUEST"
        return JSONResponse(
            error_body(codes.get(exc.status_code, default), str(exc.detail)),
            status_code=exc.status_code,
        )

    @app.exception_handler(RateLimitExceeded)
    async def _rate_limited(request: Request, exc: RateLimitExceeded):
        return JSONResponse(error_body("RATE_LIMITED", "Too many requests"), status_code=429)

    @app.exception_handler(Exception)
    async def _unexpected(request: Request, exc: Exception):
        log.exception("Unhandled error")
        return JSONResponse(error_body("SERVER_ERROR", "Internal server error"), status_code=500)