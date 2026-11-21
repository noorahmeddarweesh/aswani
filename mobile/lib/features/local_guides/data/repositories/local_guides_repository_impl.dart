import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/guide.dart';
import '../../domain/entities/guide_application.dart';
import '../../domain/entities/guide_enums.dart';
import '../../domain/entities/guide_request.dart';
import '../../domain/entities/page_meta.dart';
import '../../domain/repositories/local_guides_repository.dart';
import '../datasources/local_guides_datasource.dart';
import '../mappers/guide_application_mapper.dart';
import '../mappers/guide_mapper.dart';
import '../mappers/guide_request_mapper.dart';

class LocalGuidesRepositoryImpl implements LocalGuidesRepository {
  LocalGuidesRepositoryImpl(this._dataSource);

  final LocalGuidesDataSource _dataSource;

  Future<Result<T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Result.success(await call());
    } on AppException catch (e) {
      return Result.failure(Failure.fromException(e));
    } on Object {
      return const Result.failure(Failure.unknown);
    }
  }

  @override
  Future<Result<PagedList<Guide>>> getGuides({
    GuideSpecialty? specialty,
    String? query,
    int page = 1,
    int limit = 20,
  }) => _guard(() async {
    final dto = await _dataSource.getGuides(
      specialty: specialty?.value,
      q: query,
      page: page,
      limit: limit,
    );
    return PagedList<Guide>(
      data: dto.data.map((d) => d.toEntity()).toList(),
      meta: dto.meta.toEntity(),
    );
  });

  @override
  Future<Result<Guide>> getGuide(String id) =>
      _guard(() async => (await _dataSource.getGuide(id)).toEntity());

  @override
  Future<Result<GuideRequestResult>> createGuideRequest(
    GuideRequestCreate request,
  ) => _guard(() async {
    final dto = await _dataSource.createGuideRequest(request.toDto());
    return dto.toEntity();
  });

  @override
  Future<Result<PagedList<GuideRequestItem>>> getGuideRequestsMine({
    int page = 1,
    int limit = 20,
  }) => _guard(() async {
    final dto = await _dataSource.getGuideRequestsMine(
      page: page,
      limit: limit,
    );
    return PagedList<GuideRequestItem>(
      data: dto.data.map((d) => d.toEntity()).toList(),
      meta: dto.meta.toEntity(),
    );
  });

  @override
  Future<Result<GuideApplicationResult>> createGuideApplication(
    GuideApplicationCreate application,
  ) => _guard(() async {
    final dto = await _dataSource.createGuideApplication(application.toDto());
    return dto.toEntity();
  });
}
