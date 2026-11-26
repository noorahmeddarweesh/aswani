import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/guard.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/preferences.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../datasources/preferences_datasource.dart';
import '../mappers/preferences_mapper.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  PreferencesRepositoryImpl(this._dataSource);

  final PreferencesDataSource _dataSource;

  @override
  Future<Result<Preferences?>> load() =>
      guard(() async => (await _dataSource.load())?.toEntity());

  @override
  Future<Result<void>> save(Preferences preferences) async {
    try {
      await _dataSource.save(preferences.toDto());
      return const Result.success(null);
    } on AppException catch (e) {
      return Result.failure(Failure.fromException(e));
    } on Object {
      return const Result.failure(Failure.unknown);
    }
  }
}
