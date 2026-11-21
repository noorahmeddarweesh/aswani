import '../models/preferences_dto.dart';
import 'preferences_datasource.dart';

/// In-memory stand-in for the backend.
class PreferencesMockDataSource implements PreferencesDataSource {
  PreferencesMockDataSource({this.delay = const Duration(milliseconds: 500)});

  final Duration delay;

  /// Last saved body, for tests and debugging.
  Map<String, dynamic>? lastSaved;

  /// What GET returns before anything is saved in this run (Laila's
  /// answers, so Settings > Interests opens filled in).
  static const Map<String, dynamic> seed = {
    'persona': 'newcomer',
    'purpose': 'living',
    'stay_length': 'long_term',
    'interests': ['nubian', 'local', 'photography'],
    'travel_styles': ['cultural', 'calm'],
    'companions': 'family',
    'needs': ['finding_places', 'local_recommendations'],
    'language': 'en',
  };

  @override
  Future<PreferencesDto?> load() async {
    await Future<void>.delayed(delay);
    return PreferencesDto.fromJson(lastSaved ?? seed);
  }

  @override
  Future<void> save(PreferencesDto preferences) async {
    await Future<void>.delayed(delay);
    lastSaved = preferences.toJson();
  }
}
