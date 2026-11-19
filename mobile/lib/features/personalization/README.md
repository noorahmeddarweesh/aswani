# Personalisation

**Status:** placeholder, not implemented yet.
**Planned for:** Sprint 2.
**Owner:** _(add your name when you take this feature)_

The 8-step setup: how the user connects with Aswan, purpose, stay length, interests, style, companions, needs, and app language.

## Where things go

| Folder | Put here |
| --- | --- |
| `data/models/` | DTOs exactly like the API contract (`personalization_*_dto.dart`) |
| `data/datasources/` | `personalization_remote_datasource.dart` (dio) and `personalization_mock_datasource.dart` |
| `data/mappers/` | DTO to Entity conversion, one place only |
| `data/repositories/` | `personalization_repository_impl.dart` |
| `domain/entities/` | Clean app models (camelCase, immutable) |
| `domain/repositories/` | Abstract `PersonalizationRepository`: the interface the UI depends on |
| `presentation/screens/` | One file per screen |
| `presentation/widgets/` | Widgets used only by this feature |
| `presentation/viewmodels/` | One Riverpod Notifier per screen |

Delete the `.gitkeep` file in a folder when you add the first real file to it.
Read `docs/ARCHITECTURE.md` before starting.
