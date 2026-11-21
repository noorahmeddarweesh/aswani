import '../../../../core/result/result.dart';
import '../entities/preferences.dart';

abstract interface class PreferencesRepository {
  Future<Result<void>> save(Preferences preferences);

  /// The saved answers, or null if the user has none yet.
  Future<Result<Preferences?>> load();
}
