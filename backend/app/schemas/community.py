"""
app/schemas/community.py
────────────────────────
Pydantic schemas and types for Community social feed, posts, and comments.
"""
from __future__ import annotations

from typing import Literal, Optional
from pydantic import BaseModel, Field

PostCategory = Literal["local_experience", "nubian", "nile", "food", "other"]
SortMode = Literal["new", "top"]


class CommentIn(BaseModel):
    text: str = Field(min_length=1, max_length=1000)
