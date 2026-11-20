import '../../../../core/network/upload.dart';
import '../../../../core/pagination/paged.dart';
import '../../../../core/result/result.dart';
import '../entities/profile.dart';

abstract interface class ProfileRepository {
  Future<Result<Profile>> getProfile();

  /// Returns the new photo URL.
  Future<Result<String>> uploadAvatar(UploadFile photo);

  /// Saved places and stories; [type] null means both.
  Future<Result<Paged<SavedEntry>>> getSaved({SavedType? type, int page = 1});

  Future<Result<UserSettings>> getSettings();

  Future<Result<UserSettings>> updateSettings({
    String? languageCode,
    bool? notificationsEnabled,
  });

  Future<Result<void>> requestDeletion();
}
