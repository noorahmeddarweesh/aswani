from math import ceil


def ok(data):
    """رد عنصر واحد: { "data": ... }"""
    return {"data": data}


def paginated(items: list, page: int, limit: int, total: int):
    """رد قائمة: { "data": [...], "meta": {...} }"""
    return {
        "data": items,
        "meta": {
            "page": page,
            "limit": limit,
            "total": total,
            "total_pages": max(1, ceil(total / limit)),
        },
    }