# AI guide

**Status:** placeholder, not implemented yet.
**Planned for:** Sprint 4 or later.
**Owner:** _(add your name when you take this feature)_

Conversational AI guide and custom itinerary generation (Gemini, called through the backend).

## Where things go

| Folder | Put here |
| --- | --- |
| `data/models/` | DTOs exactly like the API contract (`chatbot_*_dto.dart`) |
| `data/datasources/` | `chatbot_remote_datasource.dart` (dio) and `chatbot_mock_datasource.dart` |
| `data/mappers/` | DTO to Entity conversion, one place only |
| `data/repositories/` | `chatbot_repository_impl.dart` |
| `domain/entities/` | Clean app models (camelCase, immutable) |
| `domain/repositories/` | Abstract `ChatbotRepository`: the interface the UI depends on |
| `presentation/screens/` | One file per screen |
| `presentation/widgets/` | Widgets used only by this feature |
| `presentation/viewmodels/` | One Riverpod Notifier per screen |

Delete the `.gitkeep` file in a folder when you add the first real file to it.
Read `docs/ARCHITECTURE.md` before starting.
