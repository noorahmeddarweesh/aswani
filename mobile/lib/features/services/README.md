# City services

**Status:** placeholder, not implemented yet.
**Planned for:** Sprint 4 or later.
**Owner:** _(add your name when you take this feature)_

Maintenance and emergency services directory; contact by call or WhatsApp.

## Where things go

| Folder | Put here |
| --- | --- |
| `data/models/` | DTOs exactly like the API contract (`services_*_dto.dart`) |
| `data/datasources/` | `services_remote_datasource.dart` (dio) and `services_mock_datasource.dart` |
| `data/mappers/` | DTO to Entity conversion, one place only |
| `data/repositories/` | `services_repository_impl.dart` |
| `domain/entities/` | Clean app models (camelCase, immutable) |
| `domain/repositories/` | Abstract `ServicesRepository`: the interface the UI depends on |
| `presentation/screens/` | One file per screen |
| `presentation/widgets/` | Widgets used only by this feature |
| `presentation/viewmodels/` | One Riverpod Notifier per screen |

Delete the `.gitkeep` file in a folder when you add the first real file to it.
Read `docs/ARCHITECTURE.md` before starting.
