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

  Future<Result<ContributionDetails>> getOne(String id);

  /// Sends the whole form again; [keepPhotos] are old photo URLs to keep,
  /// [photos] the new files. The contribution goes back to `pending`.
  Future<Result<void>> update(
    String id,
    ContributionDraft draft, {
    required List<String> keepPhotos,
    required List<UploadFile> photos,
  });
}
