"""enable rls

Revision ID: 12886796a605
Revises: 3f6fce8d38e9
Create Date: 2026-11-21 22:25:13.406541

"""
from typing import Sequence, Union

from alembic import op


# revision identifiers, used by Alembic.
revision: str = '12886796a605'
down_revision: Union[str, Sequence[str], None] = '3f6fce8d38e9'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

TABLES = [
    "users", "user_preferences", "refresh_tokens", "password_reset_codes",
    "places", "bookmarks", "alembic_version",
]


def upgrade() -> None:
    for table in TABLES:
        op.execute(f'ALTER TABLE public."{table}" ENABLE ROW LEVEL SECURITY')


def downgrade() -> None:
    for table in TABLES:
        op.execute(f'ALTER TABLE public."{table}" DISABLE ROW LEVEL SECURITY')