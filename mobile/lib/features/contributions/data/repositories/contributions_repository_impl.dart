import '../../../../core/network/upload.dart';
import '../../../../core/pagination/paged.dart';
import '../../../../core/result/guard.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/contribution.dart';
import '../../domain/repositories/contributions_repository.dart';
import '../datasources/contributions_datasource.dart';

class ContributionsRepositoryImpl implements ContributionsRepository {
  ContributionsRepositoryImpl(this._source);

  final ContributionsDataSource _source;

  @override
  Future<Result<String>> submit(
    ContributionDraft draft,
    List<UploadFile> photos,
  ) => guard(() async {
    final data = await _source.submit(_fields(draft), photos);
    return data['id'] as String;
  });

  Map<String, Object?> _fields(ContributionDraft draft) => {
    'category': draft.category.wire,
    'name': draft.name,
    'description': draft.description,
    'address': draft.address,
    'contact_number': draft.contactNumber,
  };

  @override
  Future<Result<ContributionDetails>> getOne(String id) => guard(() async {
    final j = await _source.getOne(id);
    return ContributionDetails(
      id: j['id'] as String,
      draft: ContributionDraft(
        category:
            ContributionCategory.fromWire(j['category'] as String?) ??
            ContributionCategory.other,
        name: j['name'] as String,
        description: j['description'] as String? ?? '',
        address: j['address'] as String? ?? '',
        contactNumber: j['contact_number'] as String?,
      ),
      photos: (j['photos'] as List<dynamic>? ?? const []).cast<String>(),
      status: ContributionStatus.fromWire(j['status'] as String?),
    );
  });

  @override
  Future<Result<void>> update(
    String id,
    ContributionDraft draft, {
    required List<String> keepPhotos,
    required List<UploadFile> photos,
  }) => guard(
    () => _source.update(id, {
      ..._fields(draft),
      // Sent even when empty, so the server knows every old photo goes.
      'keep_photos': keepPhotos.isEmpty ? '' : keepPhotos,
    }, photos),
  );

  @override
  Future<Result<Paged<Contribution>>> getMine({int page = 1}) => guard(
    () async => (await _source.getMine(page: page)).map(
      (j) => Contribution(
        id: j['id'] as String,
        category:
            ContributionCategory.fromWire(j['category'] as String?) ??
            ContributionCategory.other,
        name: j['name'] as String,
        status: ContributionStatus.fromWire(j['status'] as String?),
        pointsAwarded: j['points_awarded'] as int? ?? 0,
        createdAt: DateTime.parse(j['created_at'] as String),
      ),
    ),
  );
}
