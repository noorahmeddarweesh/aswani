# Places and Explore

**Status:** Explore screen + mock data implemented (Sprint 1). Place details and map still need designs.
**Planned for:** Sprint 1.
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
