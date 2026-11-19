# Culture and heritage

**Status:** placeholder, not implemented yet.
**Planned for:** Sprint 4 or later.
**Owner:** _(add your name when you take this feature)_

Illustrated cultural stories, Nubian phrasebook, site audio guides.

## Where things go

| Folder | Put here |
| --- | --- |
| `data/models/` | DTOs exactly like the API contract (`stories_*_dto.dart`) |
| `data/datasources/` | `stories_remote_datasource.dart` (dio) and `stories_mock_datasource.dart` |
| `data/mappers/` | DTO to Entity conversion, one place only |
| `data/repositories/` | `stories_repository_impl.dart` |
| `domain/entities/` | Clean app models (camelCase, immutable) |
| `domain/repositories/` | Abstract `StoriesRepository`: the interface the UI depends on |
| `presentation/screens/` | One file per screen |
| `presentation/widgets/` | Widgets used only by this feature |
| `presentation/viewmodels/` | One Riverpod Notifier per screen |

Delete the `.gitkeep` file in a folder when you add the first real file to it.
Read `docs/ARCHITECTURE.md` before starting.
