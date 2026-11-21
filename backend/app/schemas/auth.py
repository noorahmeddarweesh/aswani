"""
app/schemas/auth.py
───────────────────
Pydantic schemas for authentication and password management.
"""
from __future__ import annotations

from pydantic import BaseModel, Field, field_validator

from app.core.validators import (
    normalize_email,
    normalize_full_name,
    validate_password,
)


class RegisterIn(BaseModel):
    full_name: str
    identifier: str
    password: str

    @field_validator("full_name")
    @classmethod
    def _validate_name(cls, v: str) -> str:
        try:
            return normalize_full_name(v)
        except ValueError:
            raise ValueError("INVALID_NAME")

    @field_validator("identifier")
    @classmethod
    def _validate_identifier(cls, v: str) -> str:
        try:
            return normalize_email(v)
        except ValueError:
            raise ValueError("INVALID_EMAIL")

    @field_validator("password")
    @classmethod
    def _validate_password(cls, v: str) -> str:
        try:
            return validate_password(v)
        except ValueError:
            raise ValueError("WEAK_PASSWORD")


class LoginIn(BaseModel):
    identifier: str = Field(min_length=1, max_length=255)
    password: str = Field(min_length=1, max_length=128)


class RefreshIn(BaseModel):
    refresh_token: str = Field(min_length=1)


class ForgotPasswordIn(BaseModel):
    identifier: str = Field(min_length=1, max_length=255)


class ResetPasswordIn(BaseModel):
    identifier: str = Field(min_length=1, max_length=255)
    code: str = Field(pattern=r"^\d{4}$")
    new_password: str

    @field_validator("new_password")
    @classmethod
    def _validate_new_password(cls, v: str) -> str:
        try:
            return validate_password(v)
        except ValueError:
            raise ValueError("WEAK_PASSWORD")


class ChangePasswordIn(BaseModel):
    current_password: str = Field(min_length=1, max_length=128)
    new_password: str

    @field_validator("new_password")
    @classmethod
    def _validate_new_password(cls, v: str) -> str:
        try:
            return validate_password(v)
        except ValueError:
            raise ValueError("WEAK_PASSWORD")
