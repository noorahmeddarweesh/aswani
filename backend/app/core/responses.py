"""
app/core/responses.py
─────────────────────
Contract-compliant response builders.

The Aswani API wraps *every* success response in one of two envelopes:

  Single item / action result
  ───────────────────────────
      { "data": { ... } }

  Paginated collection
  ────────────────────
      {
        "data": [ ... ],
        "meta": {
          "page":        1,
          "limit":       20,
          "total":       45,
          "total_pages": 3
        }
      }

Routers call ok() / paginated() instead of constructing dicts manually,
so the shape is guaranteed consistent across every endpoint.
"""
from __future__ import annotations

import math
from typing import Any


def ok(data: Any) -> dict:
    """
    Wrap *data* in ``{ "data": data }``.

    Usage::

        return ok(user_schema.model_dump())
        return ok({"access_token": ..., "refresh_token": ..., "user": ...})
    """
    return {"data": data}


def paginated(
    items: list[Any],
    *,
    page: int,
    limit: int,
    total: int,
) -> dict:
    """
    Build a paginated envelope.

    Parameters
    ----------
    items  : serialisable list (already converted to dicts/scalars)
    page   : current 1-based page number
    limit  : items per page as requested
    total  : total number of records across all pages

    Usage::

        return paginated(
            [p.model_dump() for p in places],
            page=page,
            limit=limit,
            total=total_count,
        )
    """
    total_pages = max(1, math.ceil(total / limit)) if limit > 0 else 1
    return {
        "data": items,
        "meta": {
            "page": page,
            "limit": limit,
            "total": total,
            "total_pages": total_pages,
        },
    }


def no_content() -> None:
    """
    Semantic marker for 204 No Content routes.
    Routers that return None implicitly send 204; this makes intent explicit.
    """
    return None
