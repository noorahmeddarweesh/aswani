# API contract

The single source of truth for both teams: the backend implements it, the
mobile app's mock and remote data sources follow it exactly. Neither side
changes a path, field or error code alone; every agreed change raises the
version and adds a changelog line.

| File | What it is |
| --- | --- |
| [`openapi.yaml`](openapi.yaml) | Sprint 1 contract (v0.1.2), OpenAPI 3.1: all 14 endpoints with request and response bodies, errors and examples |

The written version with the reasons and the open questions is the shared
"Sprint 1 API Contract" doc. When the two differ, tell the mobile team.

## For the backend team

- **Read it:** open [editor.swagger.io](https://editor.swagger.io) and paste
  `openapi.yaml`, or install the "OpenAPI (Swagger) Editor" extension in VS Code.
- **Generate code:** most frameworks can import it (NestJS / Express with
  `openapi-generator`, ASP.NET with NSwag, FastAPI / Django REST with
  `datamodel-code-generator`), so routes and DTOs start from the contract.
- **Check your server:** every example in the file is a valid request or
  response; the mobile mock data sources return the same JSON
  (`mobile/lib/features/<feature>/data/datasources/*_mock_datasource.dart`).
- **Try the app on your server:**
  `flutter run --dart-define=USE_MOCKS=false --dart-define=BASE_URL=http://<your-ip>:3000/api`
  (from the Android emulator, the computer is `10.0.2.2`).
- Seed the demo account `laila@example.com` / `Aswan2026` (reset code `1234`)
  on staging so both teams test the same flows.

## Shared conventions

- JSON fields in `snake_case`.
- List: `{ "data": [...], "meta": { "page", "limit", "total", "total_pages" } }`
- Single item: `{ "data": { ... } }`; actions without a result: `204`.
- Error: `{ "error": { "code": "VALIDATION_ERROR", "message": "...", "details": { "field": "CODE" } } }`
- Auth: `Authorization: Bearer <access_token>`; an expired token returns
  `401 UNAUTHORIZED`, the app refreshes once (`POST /auth/refresh`) and retries.
- Language: the app sends `Accept-Language: ar` or `en`.
