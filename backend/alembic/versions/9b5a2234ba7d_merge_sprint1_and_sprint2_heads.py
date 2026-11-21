"""merge_sprint1_and_sprint2_heads

Revision ID: 9b5a2234ba7d
Revises: 12886796a605, 961684115999
Create Date: 2026-11-22 01:03:42.517924

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '9b5a2234ba7d'
down_revision: Union[str, None] = ('12886796a605', '961684115999')
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    pass


def downgrade() -> None:
    pass
