# Smart navigation

**Status:** placeholder, not implemented yet.
**Planned for:** Sprint 3 or later.
**Owner:** _(add your name when you take this feature)_

Directions with landmark cues, microbus routes and signs (Mapbox).

## Where things go

| Folder | Put here |
| --- | --- |
| `data/models/` | DTOs exactly like the API contract (`navigation_*_dto.dart`) |
| `data/datasources/` | `navigation_remote_datasource.dart` (dio) and `navigation_mock_datasource.dart` |
| `data/mappers/` | DTO to Entity conversion, one place only |
| `data/repositories/` | `navigation_repository_impl.dart` |
| `domain/entities/` | Clean app models (camelCase, immutable) |
| `domain/repositories/` | Abstract `NavigationRepository`: the interface the UI depends on |
| `presentation/screens/` | One file per screen |
| `presentation/widgets/` | Widgets used only by this feature |
| `presentation/viewmodels/` | One Riverpod Notifier per screen |

Delete the `.gitkeep` file in a folder when you add the first real file to it.
Read `docs/ARCHITECTURE.md` before starting.
