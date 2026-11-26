import '../models/guide_application_dto.dart';
import '../models/guide_dto.dart';
import '../models/guide_request_dto.dart';
import '../models/page_meta_dto.dart';

/// Datasource interface for local guides endpoints per API Contract v0.2.
abstract interface class LocalGuidesDataSource {
  /// GET /api/guides ?specialty=&q=&page=&limit=
  Future<PagedListDto<GuideDto>> getGuides({
    String? specialty,
    String? q,
    int page = 1,
    int limit = 20,
  });

  /// GET /api/guides/{id}
  Future<GuideDto> getGuide(String id);

  /// POST /api/guide-requests
  Future<GuideRequestResultDto> createGuideRequest(
    GuideRequestCreateDto request,
  );

  /// GET /api/guide-requests/mine ?page&limit
  Future<PagedListDto<GuideRequestItemDto>> getGuideRequestsMine({
    int page = 1,
    int limit = 20,
  });

  /// POST /api/guide-applications (multipart/form-data)
  Future<GuideApplicationResultDto> createGuideApplication(
    GuideApplicationCreateDto application,
  );
}
