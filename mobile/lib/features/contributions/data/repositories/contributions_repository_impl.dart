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
    final data = await _source.submit({
      'category': draft.category.wire,
      'name': draft.name,
      'description': draft.description,
      'address': draft.address,
      'contact_number': draft.contactNumber,
    }, photos);
    return data['id'] as String;
  });

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
