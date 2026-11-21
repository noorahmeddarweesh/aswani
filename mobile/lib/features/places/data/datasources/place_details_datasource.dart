import 'package:aswani/features/local_guides/data/models/page_meta_dto.dart';
import '../models/place_details_dto.dart';
import '../models/place_report_dto.dart';

/// Datasource interface for Place Details and Place Reports per API Contract v0.2.
abstract interface class PlaceDetailsDataSource {
  /// GET /api/places/{id} (extends Sprint 1 place with details)
  Future<PlaceDetailsDto> getPlaceDetails(String id);

  /// POST /api/place-reports (multipart/form-data)
  Future<PlaceReportResultDto> createPlaceReport(PlaceReportCreateDto report);

  /// GET /api/place-reports/mine ?page&limit
  Future<PagedListDto<PlaceReportItemDto>> getPlaceReportsMine({
    int page = 1,
    int limit = 20,
  });
}
