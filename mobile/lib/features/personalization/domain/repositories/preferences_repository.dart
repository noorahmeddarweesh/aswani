import '../../../../core/result/result.dart';
import '../entities/preferences.dart';

abstract interface class PreferencesRepository {
  Future<Result<void>> save(Preferences preferences);
}
