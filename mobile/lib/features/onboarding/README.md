# Welcome and onboarding

**Status:** placeholder, not implemented yet.
**Planned for:** Sprint 2.
**Owner:** _(add your name when you take this feature)_

Welcome screen and the three "Meet Aswan" intro screens.

## Where things go

| Folder | Put here |
| --- | --- |
| `data/models/` | DTOs exactly like the API contract (`onboarding_*_dto.dart`) |
| `data/datasources/` | `onboarding_remote_datasource.dart` (dio) and `onboarding_mock_datasource.dart` |
| `data/mappers/` | DTO to Entity conversion, one place only |
| `data/repositories/` | `onboarding_repository_impl.dart` |
| `domain/entities/` | Clean app models (camelCase, immutable) |
| `domain/repositories/` | Abstract `OnboardingRepository`: the interface the UI depends on |
| `presentation/screens/` | One file per screen |
| `presentation/widgets/` | Widgets used only by this feature |
| `presentation/viewmodels/` | One Riverpod Notifier per screen |

Delete the `.gitkeep` file in a folder when you add the first real file to it.
Read `docs/ARCHITECTURE.md` before starting.
