import '../../../../core/network/upload.dart';
import '../../../../core/pagination/paged.dart';

/// Profile & Settings endpoints (contract v0.2, Person B — Profile &
/// Settings). Returns the `data` part of each response as JSON maps.
abstract interface class ProfileDataSource {
  /// GET /api/users/me/profile
  Future<Map<String, dynamic>> getProfile();

  /// PUT /api/users/me/avatar (multipart `avatar`) → the new URL.
  Future<String> uploadAvatar(UploadFile photo);

  /// GET /api/saved?type=&page=&limit=
  Future<Paged<Map<String, dynamic>>> getSaved({String? type, int page = 1});

  /// GET /api/users/settings
  Future<Map<String, dynamic>> getSettings();

  /// PATCH /api/users/settings
  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> body);

  /// POST /api/users/me/deletion-request
  Future<void> requestDeletion();
}
