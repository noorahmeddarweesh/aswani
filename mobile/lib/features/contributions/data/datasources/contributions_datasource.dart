import '../../../../core/network/upload.dart';
import '../../../../core/pagination/paged.dart';

/// Contribution endpoints of contract v0.3 (JSON in, JSON out).
abstract interface class ContributionsDataSource {
  /// POST /api/contributions (multipart) -> `{ id, status }`
  Future<Map<String, dynamic>> submit(
    Map<String, Object?> fields,
    List<UploadFile> photos,
  );

  /// GET /api/contributions/mine?page=&limit=
  Future<Paged<Map<String, dynamic>>> getMine({int page = 1});

  /// GET /api/contributions/{id} (v0.3)
  Future<Map<String, dynamic>> getOne(String id);

  /// PATCH /api/contributions/{id} (multipart, v0.3)
  Future<Map<String, dynamic>> update(
    String id,
    Map<String, Object?> fields,
    List<UploadFile> photos,
  );
}
