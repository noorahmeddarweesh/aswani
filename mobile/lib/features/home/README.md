# Home

**Status:** placeholder, not implemented yet.
**Planned for:** Sprint 3.
**Owner:** _(add your name when you take this feature)_

Home screen: greeting, search, explore categories, curated places, stories teaser, local guides, community call-to-action.

## Where things go

| Folder | Put here |
| --- | --- |
| `data/models/` | DTOs exactly like the API contract (`home_*_dto.dart`) |
| `data/datasources/` | `home_remote_datasource.dart` (dio) and `home_mock_datasource.dart` |
| `data/mappers/` | DTO to Entity conversion, one place only |
| `data/repositories/` | `home_repository_impl.dart` |
| `domain/entities/` | Clean app models (camelCase, immutable) |
| `domain/repositories/` | Abstract `HomeRepository`: the interface the UI depends on |
| `presentation/screens/` | One file per screen |
| `presentation/widgets/` | Widgets used only by this feature |
| `presentation/viewmodels/` | One Riverpod Notifier per screen |

Delete the `.gitkeep` file in a folder when you add the first real file to it.
Read `docs/ARCHITECTURE.md` before starting.
