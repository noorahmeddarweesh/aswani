# Places and Explore

**Status:** placeholder, not implemented yet.
**Planned for:** Sprint 3.
**Owner:** _(add your name when you take this feature)_

Explore screen, search and filters, place details, saved places (bookmarks).

## Where things go

| Folder | Put here |
| --- | --- |
| `data/models/` | DTOs exactly like the API contract (`places_*_dto.dart`) |
| `data/datasources/` | `places_remote_datasource.dart` (dio) and `places_mock_datasource.dart` |
| `data/mappers/` | DTO to Entity conversion, one place only |
| `data/repositories/` | `places_repository_impl.dart` |
| `domain/entities/` | Clean app models (camelCase, immutable) |
| `domain/repositories/` | Abstract `PlacesRepository`: the interface the UI depends on |
| `presentation/screens/` | One file per screen |
| `presentation/widgets/` | Widgets used only by this feature |
| `presentation/viewmodels/` | One Riverpod Notifier per screen |

Delete the `.gitkeep` file in a folder when you add the first real file to it.
Read `docs/ARCHITECTURE.md` before starting.
