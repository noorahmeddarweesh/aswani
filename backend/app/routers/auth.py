"""
app/routers/auth.py
───────────────────
Authentication, token refresh, and password recovery endpoints.
"""
from fastapi import APIRouter, BackgroundTasks, Depends, Request, Response
from sqlalchemy.orm import Session

from app.core.deps import get_current_user_id, get_db
from app.core.limiter import limiter
from app.core.responses import ok
from app.schemas.auth import (
    ChangePasswordIn,
    ForgotPasswordIn,
    LoginIn,
    RefreshIn,
    RegisterIn,
    ResetPasswordIn,
)
from app.services import auth_service
from app.services.email_service import send_reset_code

router = APIRouter(prefix="/auth", tags=["Auth"])


@router.post("/register", status_code=201)
@limiter.limit("10/minute")
def register(request: Request, body: RegisterIn, db: Session = Depends(get_db)):
    result = auth_service.register(
        db,
        full_name=body.full_name,
        identifier=body.identifier,
        password=body.password,
    )
    return ok(result)


@router.post("/login")
@limiter.limit("10/minute")
def login(request: Request, body: LoginIn, db: Session = Depends(get_db)):
    result = auth_service.login(
        db,
        identifier=body.identifier,
        password=body.password,
    )
    return ok(result)


@router.post("/refresh")
@limiter.limit("30/minute")
def refresh(request: Request, body: RefreshIn, db: Session = Depends(get_db)):
    result = auth_service.refresh(db, body.refresh_token)
    return ok(result)


@router.post("/logout", status_code=204)
def logout(body: RefreshIn, user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    auth_service.logout(db, user_id, body.refresh_token)
    return Response(status_code=204)


@router.post("/forgot-password", status_code=204)
@limiter.limit("5/minute")
def forgot_password(
    request: Request,
    body: ForgotPasswordIn,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db),
):
    email, code, should_send = auth_service.forgot_password(db, body.identifier)
    if should_send:
        background_tasks.add_task(send_reset_code, email, code)
    return Response(status_code=204)


@router.post("/reset-password", status_code=204)
@limiter.limit("10/minute")
def reset_password(request: Request, body: ResetPasswordIn, db: Session = Depends(get_db)):
    auth_service.reset_password(
        db,
        identifier=body.identifier,
        code=body.code,
        new_password=body.new_password,
    )
    return Response(status_code=204)


@router.post("/change-password", status_code=204)
def change_password(
    body: ChangePasswordIn,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    auth_service.change_password(
        db,
        user_id=user_id,
        current_password=body.current_password,
        new_password=body.new_password,
    )
    return Response(status_code=204)
