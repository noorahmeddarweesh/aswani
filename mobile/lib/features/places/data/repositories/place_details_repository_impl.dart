import 'package:aswani/core/errors/app_exception.dart';
import 'package:aswani/core/errors/failure.dart';
import 'package:aswani/core/result/result.dart';
import 'package:aswani/features/local_guides/data/mappers/guide_mapper.dart';
import 'package:aswani/features/local_guides/domain/entities/page_meta.dart';
import 'package:aswani/features/places/data/datasources/place_details_datasource.dart';
import 'package:aswani/features/places/data/mappers/place_details_mapper.dart';
import 'package:aswani/features/places/data/mappers/place_report_mapper.dart';
import 'package:aswani/features/places/domain/entities/place_details.dart';
import 'package:aswani/features/places/domain/entities/place_report.dart';
import 'package:aswani/features/places/domain/repositories/place_details_repository.dart';

class PlaceDetailsRepositoryImpl implements PlaceDetailsRepository {
  PlaceDetailsRepositoryImpl(this._dataSource);

  final PlaceDetailsDataSource _dataSource;

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
  Future<Result<PlaceDetails>> getPlaceDetails(String id) =>
      _guard(() async => (await _dataSource.getPlaceDetails(id)).toEntity());

  @override
  Future<Result<PlaceReportResult>> createPlaceReport(
    PlaceReportCreate report,
  ) => _guard(() async {
    final dto = await _dataSource.createPlaceReport(report.toDto());
    return dto.toEntity();
  });

  @override
  Future<Result<PagedList<PlaceReportItem>>> getPlaceReportsMine({
    int page = 1,
    int limit = 20,
  }) => _guard(() async {
    final dto = await _dataSource.getPlaceReportsMine(page: page, limit: limit);
    return PagedList<PlaceReportItem>(
      data: dto.data.map((d) => d.toEntity()).toList(),
      meta: dto.meta.toEntity(),
    );
  });
}
