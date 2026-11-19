import '../models/preferences_dto.dart';

abstract interface class PreferencesDataSource {
  /// PUT /api/users/preferences
  Future<void> save(PreferencesDto preferences);
}
