from fastapi import APIRouter

from app.core.responses import ok
from app.deps import CurrentUser
from app.services.auth_service import user_to_dict

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/me")
def me(user: CurrentUser):
    return ok(user_to_dict(user))