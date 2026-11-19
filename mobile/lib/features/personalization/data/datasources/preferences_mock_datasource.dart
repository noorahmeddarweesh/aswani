import '../models/preferences_dto.dart';
import 'preferences_datasource.dart';

/// In-memory stand-in for the backend.
class PreferencesMockDataSource implements PreferencesDataSource {
  PreferencesMockDataSource({this.delay = const Duration(milliseconds: 500)});

  final Duration delay;

  /// Last saved body, for tests and debugging.
  Map<String, dynamic>? lastSaved;

  @override
  Future<void> save(PreferencesDto preferences) async {
    await Future<void>.delayed(delay);
    lastSaved = preferences.toJson();
  }
}
