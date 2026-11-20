import '../../../../core/network/upload.dart';
import '../../../../core/pagination/paged.dart';
import '../../../../core/result/result.dart';
import '../entities/contribution.dart';

abstract interface class ContributionsRepository {
  /// Returns the new contribution's id (status `pending`).
  Future<Result<String>> submit(
    ContributionDraft draft,
    List<UploadFile> photos,
  );

  Future<Result<Paged<Contribution>>> getMine({int page = 1});
}
