from fastapi import APIRouter, BackgroundTasks, Request, Response

from app.core.limiter import limiter
from app.core.responses import ok
from app.deps import CurrentUser, DbSession
from app.schemas.auth import ForgotPasswordIn, LoginIn, RefreshIn, RegisterIn, ResetPasswordIn
from app.services import auth_service
from app.services.email_service import send_reset_code

router = APIRouter(prefix="/auth", tags=["auth"])


# ملاحظة: @limiter.limit لازم تكون تحت @router.post، ولازم الدالة فيها متغير اسمه request
@router.post("/register", status_code=201)
@limiter.limit("10/minute")
def register(request: Request, body: RegisterIn, db: DbSession):
    return ok(auth_service.register(db, body.full_name, body.identifier, body.password))


@router.post("/login")
@limiter.limit("10/minute")
def login(request: Request, body: LoginIn, db: DbSession):
    return ok(auth_service.login(db, body.identifier, body.password))


@router.post("/refresh")
@limiter.limit("30/minute")
def refresh(request: Request, body: RefreshIn, db: DbSession):
    return ok(auth_service.refresh(db, body.refresh_token))


@router.post("/logout", status_code=204)
def logout(body: RefreshIn, user: CurrentUser, db: DbSession):
    auth_service.logout(db, user, body.refresh_token)
    return Response(status_code=204)


@router.post("/forgot-password", status_code=204)
@limiter.limit("5/minute")
def forgot_password(request: Request, body: ForgotPasswordIn, db: DbSession, background: BackgroundTasks):
    email, code, should_send = auth_service.forgot_password(db, body.identifier)
    if should_send:
        background.add_task(send_reset_code, email, code)  # الإيميل بيتبعت بعد الرد
    return Response(status_code=204)


@router.post("/reset-password", status_code=204)
@limiter.limit("10/minute")
def reset_password(request: Request, body: ResetPasswordIn, db: DbSession):
    auth_service.reset_password(db, body.identifier, body.code, body.new_password)
    return Response(status_code=204)