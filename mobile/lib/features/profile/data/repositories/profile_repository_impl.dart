import '../../../../core/network/upload.dart';
import '../../../../core/pagination/paged.dart';
import '../../../../core/result/guard.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_datasource.dart';
import '../mappers/profile_mappers.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._dataSource);

  final ProfileDataSource _dataSource;

  @override
  Future<Result<Profile>> getProfile() =>
      guard(() async => profileFromJson(await _dataSource.getProfile()));

  @override
  Future<Result<String>> uploadAvatar(UploadFile photo) =>
      guard(() => _dataSource.uploadAvatar(photo));

  @override
  Future<Result<Paged<SavedEntry>>> getSaved({SavedType? type, int page = 1}) =>
      guard(() async {
        final raw = await _dataSource.getSaved(type: type?.wire, page: page);
        return Paged(
          items: [for (final e in raw.items) ?savedEntryFromJson(e)],
          page: raw.page,
          totalPages: raw.totalPages,
          total: raw.total,
        );
      });

  @override
  Future<Result<UserSettings>> getSettings() =>
      guard(() async => settingsFromJson(await _dataSource.getSettings()));

  @override
  Future<Result<UserSettings>> updateSettings({
    String? languageCode,
    bool? notificationsEnabled,
  }) => guard(
    () async => settingsFromJson(
      await _dataSource.updateSettings({
        'language': ?languageCode,
        'notifications_enabled': ?notificationsEnabled,
      }),
    ),
  );

  @override
  Future<Result<void>> requestDeletion() => guard(_dataSource.requestDeletion);
}
