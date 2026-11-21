import '../../../../core/result/result.dart';
import '../entities/guide.dart';
import '../entities/guide_application.dart';
import '../entities/guide_enums.dart';
import '../entities/guide_request.dart';
import '../entities/page_meta.dart';

/// Repository contract for local guides features.
abstract interface class LocalGuidesRepository {
  /// Fetches a paginated list of guides, with optional specialty and search query.
  Future<Result<PagedList<Guide>>> getGuides({
    GuideSpecialty? specialty,
    String? query,
    int page = 1,
    int limit = 20,
  });

  /// Fetches details for a single guide by ID.
  Future<Result<Guide>> getGuide(String id);

  /// Submits a request to book a guide.
  Future<Result<GuideRequestResult>> createGuideRequest(
    GuideRequestCreate request,
  );

  /// Fetches the user's submitted guide requests.
  Future<Result<PagedList<GuideRequestItem>>> getGuideRequestsMine({
    int page = 1,
    int limit = 20,
  });

  /// Submits an application to become a local guide.
  Future<Result<GuideApplicationResult>> createGuideApplication(
    GuideApplicationCreate application,
  );
}
