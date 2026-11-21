from pydantic import BaseModel, Field, field_validator

from app.core.validators import check_email, check_full_name, check_password


class RegisterIn(BaseModel):
    full_name: str
    identifier: str
    password: str

    @field_validator("full_name")
    @classmethod
    def _name(cls, v: str) -> str:
        return check_full_name(v)

    @field_validator("identifier")
    @classmethod
    def _identifier(cls, v: str) -> str:
        return check_email(v)

    @field_validator("password")
    @classmethod
    def _password(cls, v: str) -> str:
        return check_password(v)


class LoginIn(BaseModel):
    identifier: str = Field(min_length=1, max_length=255)
    password: str = Field(min_length=1, max_length=128)


class RefreshIn(BaseModel):  # نفسه للـ logout
    refresh_token: str = Field(min_length=1)


class ForgotPasswordIn(BaseModel):
    identifier: str = Field(min_length=1, max_length=255)


class ResetPasswordIn(BaseModel):
    identifier: str = Field(min_length=1, max_length=255)
    code: str = Field(pattern=r"^\d{4}$")  # 4 أرقام بالظبط
    new_password: str

    @field_validator("new_password")
    @classmethod
    def _password(cls, v: str) -> str:
        return check_password(v)