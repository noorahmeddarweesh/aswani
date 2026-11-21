"""enable_rls

Revision ID: 961684115999
Revises: a2b7b36ef529
Create Date: 2026-11-21 21:15:57.291167

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '961684115999'
down_revision: Union[str, None] = 'a2b7b36ef529'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

TABLES = [
    "users",
    "user_preferences",
    "refresh_tokens",
    "password_reset_codes",
    "places",
    "bookmarks",
    "posts",
    "post_likes",
    "post_bookmarks",
    "comments",
    "highlights",
    "culture_themes",
    "stories",
    "story_saves",
    "guides",
    "guide_requests",
    "guide_applications",
    "place_reports",
    "contributions",
    "deletion_requests",
    "alembic_version",
]


def upgrade() -> None:
    bind = op.get_bind()
    if bind.dialect.name == "postgresql":
        for table in TABLES:
            op.execute(f'ALTER TABLE public."{table}" ENABLE ROW LEVEL SECURITY')


def downgrade() -> None:
    bind = op.get_bind()
    if bind.dialect.name == "postgresql":
        for table in TABLES:
            op.execute(f'ALTER TABLE public."{table}" DISABLE ROW LEVEL SECURITY')
