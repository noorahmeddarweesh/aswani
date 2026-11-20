import '../../../../core/network/upload.dart';
import '../../../../core/pagination/paged.dart';

/// Contribution endpoints of contract v0.2 (JSON in, JSON out).
abstract interface class ContributionsDataSource {
  /// POST /api/contributions (multipart) -> `{ id, status }`
  Future<Map<String, dynamic>> submit(
    Map<String, Object?> fields,
    List<UploadFile> photos,
  );

  /// GET /api/contributions/mine?page=&limit=
  Future<Paged<Map<String, dynamic>>> getMine({int page = 1});
}
