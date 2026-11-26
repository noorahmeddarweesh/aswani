"""
app/core/errors.py
──────────────────
Unified error handling for Aswani.

Every 4xx / 5xx that leaves the server must be in the contract envelope:

    {
      "error": {
        "code":    "SOME_ERROR_CODE",
        "message": "Human-readable diagnostic (not shown to users)",
        "details": { "field_name": "ERROR_SUBCODE" }
      }
    }

The mobile app reads `error.code` and `error.details` to display the
localised string from AppLocalizations.errorFor(code).  It never shows
`error.message`.

Usage:
    raise AppError(404, "PLACE_NOT_FOUND", "No place with id=abc")
    raise AppError(422, "VALIDATION_ERROR", details={"email": "INVALID_EMAIL"})
"""
from __future__ import annotations

import logging
import traceback
from typing import Any

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException
from starlette.status import (
    HTTP_400_BAD_REQUEST,
    HTTP_401_UNAUTHORIZED,
    HTTP_403_FORBIDDEN,
    HTTP_404_NOT_FOUND,
    HTTP_405_METHOD_NOT_ALLOWED,
    HTTP_409_CONFLICT,
    HTTP_422_UNPROCESSABLE_ENTITY,
    HTTP_429_TOO_MANY_REQUESTS,
    HTTP_500_INTERNAL_SERVER_ERROR,
)

from app.core.config import settings

logger = logging.getLogger(__name__)


# ─── Domain Error ─────────────────────────────────────────────────────────────

class AppError(Exception):
    """
    Raise this anywhere in a service to signal a known business error.

    Parameters
    ----------
    status_code : int
        HTTP status code the router should return.
    code : str
        Contract error code, e.g. ``"PLACE_NOT_FOUND"``.  The mobile app
        maps this to a localised string.
    message : str
        Diagnostic message written to logs only — never shown in the UI.
    details : dict[str, str]
        Field-level errors, e.g. ``{"email": "EMAIL_ALREADY_EXISTS"}``.
        The mobile form shows these under the matching input widget.
    """

    def __init__(
        self,
        status_code: int,
        code: str,
        message: str = "",
        details: dict[str, str] | None = None,
    ) -> None:
        super().__init__(message or code)
        self.status_code = status_code
        self.code = code
        self.message = message or code
        self.details: dict[str, str] = details or {}


# ─── Response builder ─────────────────────────────────────────────────────────

def _error_response(
    status_code: int,
    code: str,
    message: str,
    details: dict[str, str] | None = None,
) -> JSONResponse:
    body: dict[str, Any] = {"error": {"code": code, "message": message}}
    if details:
        body["error"]["details"] = details
    return JSONResponse(status_code=status_code, content=body)


# ─── Pydantic v2 → contract field errors ─────────────────────────────────────

def _pydantic_details(exc: RequestValidationError) -> dict[str, str]:
    """
    Map Pydantic v2 validation errors to the contract's field-level dict.

    Example output: ``{"email": "VALIDATION_ERROR", "password": "VALIDATION_ERROR"}``
    """
    out: dict[str, str] = {}
    for err in exc.errors():
        # loc is a tuple like ("body", "email") or ("query", "page")
        loc = err.get("loc", ())
        field = str(loc[-1]) if loc else "body"
        msg_type = err.get("type", "")
        # Give specific contract codes where we can
        if "missing" in msg_type:
            out[field] = "REQUIRED"
        elif "email" in msg_type:
            out[field] = "INVALID_EMAIL"
        else:
            out[field] = "VALIDATION_ERROR"
    return out


# ─── Handler registration ─────────────────────────────────────────────────────

def register_error_handlers(app: FastAPI) -> None:
    """
    Attach all exception handlers to *app*.
    Call this once in create_app() after the FastAPI instance is created.
    """

    @app.exception_handler(AppError)
    async def handle_app_error(request: Request, exc: AppError) -> JSONResponse:  # noqa: RUF029
        if exc.status_code >= HTTP_500_INTERNAL_SERVER_ERROR:
            logger.error("AppError 5xx: %s %s — %s", request.method, request.url, exc.message)
        return _error_response(exc.status_code, exc.code, exc.message, exc.details or None)

    @app.exception_handler(RequestValidationError)
    async def handle_validation_error(  # noqa: RUF029
        request: Request, exc: RequestValidationError
    ) -> JSONResponse:
        details = _pydantic_details(exc)
        return _error_response(
            HTTP_422_UNPROCESSABLE_ENTITY,
            "VALIDATION_ERROR",
            "Request body or query parameters failed validation.",
            details or None,
        )

    @app.exception_handler(StarletteHTTPException)
    async def handle_http_exception(  # noqa: RUF029
        request: Request, exc: StarletteHTTPException
    ) -> JSONResponse:
        # Map generic HTTP codes to our contract codes
        code_map: dict[int, str] = {
            HTTP_400_BAD_REQUEST: "BAD_REQUEST",
            HTTP_401_UNAUTHORIZED: "UNAUTHORIZED",
            HTTP_403_FORBIDDEN: "FORBIDDEN",
            HTTP_404_NOT_FOUND: "NOT_FOUND",
            HTTP_405_METHOD_NOT_ALLOWED: "METHOD_NOT_ALLOWED",
            HTTP_409_CONFLICT: "CONFLICT",
            HTTP_422_UNPROCESSABLE_ENTITY: "VALIDATION_ERROR",
            HTTP_429_TOO_MANY_REQUESTS: "TOO_MANY_REQUESTS",
        }
        code = code_map.get(exc.status_code, "SERVER_ERROR")
        message = exc.detail if isinstance(exc.detail, str) else str(exc.detail)
        return _error_response(exc.status_code, code, message)

    @app.exception_handler(Exception)
    async def handle_unhandled_exception(  # noqa: RUF029
        request: Request, exc: Exception
    ) -> JSONResponse:
        logger.error(
            "Unhandled exception on %s %s:\n%s",
            request.method,
            request.url,
            traceback.format_exc(),
        )
        message = str(exc) if settings.APP_DEBUG else "An unexpected error occurred."
        return _error_response(
            HTTP_500_INTERNAL_SERVER_ERROR,
            "SERVER_ERROR",
            message,
        )
