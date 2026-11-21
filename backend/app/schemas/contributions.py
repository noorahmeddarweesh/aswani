"""
app/schemas/contributions.py
────────────────────────────
Types and allowed values for user place contributions.
"""
from __future__ import annotations

from typing import Literal

ContributionCategory = Literal[
    "restaurant", "cafe", "entertainment", "maintenance", "clinic", "other"
]
ContributionStatus = Literal["pending", "accepted", "rejected"]
