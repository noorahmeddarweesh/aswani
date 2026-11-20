import '../models/preferences_dto.dart';

abstract interface class PreferencesDataSource {
  /// PUT /api/users/preferences
  Future<void> save(PreferencesDto preferences);

  /// GET /api/users/preferences (same body as PUT), or null if none saved.
  Future<PreferencesDto?> load();
}
