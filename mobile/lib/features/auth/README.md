# Authentication

**Status:** UI + mock data implemented (Sprint 1). Remote data source waits for the backend endpoints.
**Planned for:** Sprint 1.
**Owner:** _(add your name when you take this feature)_

Sign in, sign up, forgot password, reset password, keeping the user signed in (JWT access + refresh tokens).

## Where things go

| Folder | Put here |
| --- | --- |
| `data/models/` | DTOs exactly like the API contract (`auth_*_dto.dart`) |
| `data/datasources/` | `auth_remote_datasource.dart` (dio) and `auth_mock_datasource.dart` |
| `data/mappers/` | DTO to Entity conversion, one place only |
| `data/repositories/` | `auth_repository_impl.dart` |
| `domain/entities/` | Clean app models (camelCase, immutable) |
| `domain/repositories/` | Abstract `AuthRepository`: the interface the UI depends on |
| `presentation/screens/` | One file per screen |
| `presentation/widgets/` | Widgets used only by this feature |
| `presentation/viewmodels/` | One Riverpod Notifier per screen |

Delete the `.gitkeep` file in a folder when you add the first real file to it.
Read `docs/ARCHITECTURE.md` before starting.
