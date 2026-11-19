# Community hub

**Status:** placeholder, not implemented yet.
**Planned for:** Sprint 3 or later.
**Owner:** _(add your name when you take this feature)_

Questions and answers, replies, upvotes, local advice.

## Where things go

| Folder | Put here |
| --- | --- |
| `data/models/` | DTOs exactly like the API contract (`community_*_dto.dart`) |
| `data/datasources/` | `community_remote_datasource.dart` (dio) and `community_mock_datasource.dart` |
| `data/mappers/` | DTO to Entity conversion, one place only |
| `data/repositories/` | `community_repository_impl.dart` |
| `domain/entities/` | Clean app models (camelCase, immutable) |
| `domain/repositories/` | Abstract `CommunityRepository`: the interface the UI depends on |
| `presentation/screens/` | One file per screen |
| `presentation/widgets/` | Widgets used only by this feature |
| `presentation/viewmodels/` | One Riverpod Notifier per screen |

Delete the `.gitkeep` file in a folder when you add the first real file to it.
Read `docs/ARCHITECTURE.md` before starting.
