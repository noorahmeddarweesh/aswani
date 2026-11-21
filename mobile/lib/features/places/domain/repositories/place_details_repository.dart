import 'package:aswani/core/result/result.dart';
import 'package:aswani/features/local_guides/domain/entities/page_meta.dart';
import '../entities/place_details.dart';
import '../entities/place_report.dart';

/// Repository interface for Place Details and Place Reports per API Contract v0.2.
abstract interface class PlaceDetailsRepository {
  /// Fetches extended place details by ID (location, about, images, facts).
  Future<Result<PlaceDetails>> getPlaceDetails(String id);

  /// Submits a place issue report.
  Future<Result<PlaceReportResult>> createPlaceReport(PlaceReportCreate report);

  /// Fetches the user's submitted place reports.
  Future<Result<PagedList<PlaceReportItem>>> getPlaceReportsMine({
    int page = 1,
    int limit = 20,
  });
}
