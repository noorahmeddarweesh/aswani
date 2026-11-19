import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/place.dart';
import '../../domain/repositories/places_repository.dart';
import '../datasources/places_datasource.dart';
import '../mappers/place_mapper.dart';

class PlacesRepositoryImpl implements PlacesRepository {
  PlacesRepositoryImpl(this._dataSource);

  final PlacesDataSource _dataSource;

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
  Future<Result<List<Place>>> getPlaces({PlaceCategory? category}) =>
      _guard(() async {
        final list = await _dataSource.getPlaces(category: category?.name);
        return list.map((d) => d.toEntity()).toList();
      });

  @override
  Future<Result<List<Place>>> getCurated() => _guard(() async {
    final list = await _dataSource.getCurated();
    return list.map((d) => d.toEntity()).toList();
  });

  @override
  Future<Result<Place>> setBookmark(String placeId, {required bool saved}) =>
      _guard(
        () async =>
            (await _dataSource.setBookmark(placeId, saved: saved)).toEntity(),
      );
}
