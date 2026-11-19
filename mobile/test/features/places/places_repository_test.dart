import 'package:aswani/core/result/result.dart';
import 'package:aswani/features/places/data/datasources/places_mock_datasource.dart';
import 'package:aswani/features/places/data/repositories/places_repository_impl.dart';
import 'package:aswani/features/places/domain/entities/place.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PlacesRepositoryImpl repository;

  setUp(() {
    repository = PlacesRepositoryImpl(
      PlacesMockDataSource(delay: Duration.zero),
    );
  });

  test('filters places by category', () async {
    final all = (await repository.getPlaces() as Success<List<Place>>).value;
    final history = (await repository.getPlaces(
      category: PlaceCategory.history,
    ) as Success<List<Place>>).value;
    expect(all.length, 4);
    expect(history.every((p) => p.category == PlaceCategory.history), isTrue);
    expect(history.length, 2);
  });

  test('bookmark toggles on and off and is remembered', () async {
    final on = (await repository.setBookmark(
      'philae',
      saved: true,
    ) as Success<Place>).value;
    expect(on.isBookmarked, isTrue);
    final curated =
        (await repository.getCurated() as Success<List<Place>>).value;
    expect(curated.firstWhere((p) => p.id == 'philae').isBookmarked, isTrue);
    final off = (await repository.setBookmark(
      'philae',
      saved: false,
    ) as Success<Place>).value;
    expect(off.isBookmarked, isFalse);
  });

  test('names are given in both languages', () async {
    final place =
        (await repository.getCurated() as Success<List<Place>>).value.first;
    expect(place.name('en'), 'Philae Temple');
    expect(place.name('ar'), 'معبد فيلة');
  });
}
