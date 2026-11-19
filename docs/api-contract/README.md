# API contract

One file per module (`auth.md`, `preferences.md`, `places.md`, ...), each with a
version number and a changelog. Both teams build against these files: the
backend implements them, the mobile app's mock data sources copy them exactly.

Shared conventions:

- JSON fields in `snake_case`.
- List: `{ "data": [...], "meta": { "page", "limit", "total", "total_pages" } }`
- Single item: `{ "data": { ... } }`
- Error: `{ "error": { "code": "VALIDATION_ERROR", "message": "...", "details": { "field": "..." } } }`
- Auth: `Authorization: Bearer <access_token>`
