import 'package:aswani/core/errors/app_exception.dart';
import 'package:aswani/core/errors/failure.dart';
import 'package:aswani/core/result/result.dart';
import 'package:aswani/features/local_guides/domain/entities/page_meta.dart';
import 'package:aswani/features/places/domain/entities/place.dart';
import 'package:aswani/features/places/domain/entities/place_details.dart';
import 'package:aswani/features/places/domain/entities/place_report.dart';
import 'package:aswani/features/places/domain/repositories/place_details_repository.dart';
import 'package:aswani/features/places/domain/repositories/places_repository.dart';
import 'package:aswani/features/places/place_details_providers.dart';
import 'package:aswani/features/places/places_providers.dart';
import 'package:aswani/features/places/presentation/viewmodels/place_details_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePlaceDetailsRepo implements PlaceDetailsRepository {
  _FakePlaceDetailsRepo({
    this.failWithNotFound = false,
    this.failWithGeneric = false,
  });

  bool failWithNotFound;
  bool failWithGeneric;

  static const samplePlace = Place(
    id: 'philae',
    category: PlaceCategory.history,
    nameEn: 'Philae Temple',
    nameAr: 'معبد فيلة',
    labelEn: 'Heritage & history',
    labelAr: 'تراث وتاريخ',
    taglineEn: 'History on an island',
    taglineAr: 'تاريخ على جزيرة',
    cityEn: 'Aswan',
    cityAr: 'أسوان',
    imagePath: 'assets/images/places/philae_temple.jpg',
    isCurated: true,
    isEditorsPick: true,
    isBookmarked: false,
  );

  static const sampleDetails = PlaceDetails(
    place: samplePlace,
    locationEn: 'Agilkia Island, Aswan',
    locationAr: 'جزيرة أجيليكيا، أسوان',
    aboutEn: 'An archaeological complex on an island in the Nile.',
    aboutAr: 'مجمع أثري على جزيرة في النيل.',
    images: [
      'assets/images/places/philae_temple.jpg',
      'assets/images/places/philae_temple.jpg',
    ],
    facts: [
      PlaceFact(type: 'access', labelEn: 'Boat access', labelAr: 'الوصول بالقارب'),
      PlaceFact(type: 'hours', labelEn: 'Check before visiting', labelAr: 'تحقق قبل الزيارة'),
    ],
  );

  @override
  Future<Result<PlaceDetails>> getPlaceDetails(String id) async {
    if (failWithNotFound || id == 'unknown') {
      return Result.failure(
        Failure.fromException(
          const AppException(
            code: ErrorCodes.placeNotFound,
            statusCode: 404,
            message: 'Place not found',
          ),
        ),
      );
    }
    if (failWithGeneric) {
      return const Result.failure(Failure.unknown);
    }
    return const Result.success(sampleDetails);
  }

  @override
  Future<Result<PlaceReportResult>> createPlaceReport(PlaceReportCreate report) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<PagedList<PlaceReportItem>>> getPlaceReportsMine({int page = 1, int limit = 20}) async {
    throw UnimplementedError();
  }
}

class _FakePlacesRepo implements PlacesRepository {
  _FakePlacesRepo({this.failBookmark = false});

  bool failBookmark;
  bool lastSavedState = false;

  @override
  Future<Result<List<Place>>> getPlaces({PlaceCategory? category}) async =>
      const Result.success([]);

  @override
  Future<Result<List<Place>>> getCurated() async => const Result.success([]);

  @override
  Future<Result<Place>> setBookmark(String placeId, {required bool saved}) async {
    if (failBookmark) {
      return const Result.failure(Failure(ErrorCodes.noConnection));
    }
    lastSavedState = saved;
    final updated = _FakePlaceDetailsRepo.samplePlace.copyWith(isBookmarked: saved);
    return Result.success(updated);
  }
}

extension on Place {
  Place copyWith({bool? isBookmarked}) {
    return Place(
      id: id,
      category: category,
      nameEn: nameEn,
      nameAr: nameAr,
      labelEn: labelEn,
      labelAr: labelAr,
      taglineEn: taglineEn,
      taglineAr: taglineAr,
      cityEn: cityEn,
      cityAr: cityAr,
      imagePath: imagePath,
      isCurated: isCurated,
      isEditorsPick: isEditorsPick,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}

void main() {
  group('PlaceDetailsViewModel', () {
    late _FakePlaceDetailsRepo detailsRepo;
    late _FakePlacesRepo placesRepo;
    late ProviderContainer container;

    setUp(() {
      detailsRepo = _FakePlaceDetailsRepo();
      placesRepo = _FakePlacesRepo();
      container = ProviderContainer(
        overrides: [
          placeDetailsRepositoryProvider.overrideWithValue(detailsRepo),
          placesRepositoryProvider.overrideWithValue(placesRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('initial build loads PlaceDetails successfully', () async {
      container.listen(placeDetailsViewModelProvider('philae'), (_, _) {});
      await Future<void>.delayed(Duration.zero);

      final state = container.read(placeDetailsViewModelProvider('philae'));
      expect(state.hasValue, isTrue);
      final details = state.value!;
      expect(details.id, 'philae');
      expect(details.nameEn, 'Philae Temple');
      expect(details.locationEn, 'Agilkia Island, Aswan');
      expect(details.facts.length, 2);
      expect(details.isBookmarked, isFalse);
    });

    test('initial build handles 404 PLACE_NOT_FOUND', () async {
      detailsRepo.failWithNotFound = true;
      container.listen(placeDetailsViewModelProvider('unknown'), (_, _) {});
      await Future<void>.delayed(Duration.zero);

      final state = container.read(placeDetailsViewModelProvider('unknown'));
      expect(state.hasError, isTrue);
      expect(
        state.error,
        isA<Failure>().having((f) => f.code, 'code', ErrorCodes.placeNotFound),
      );
    });

    test('retry re-attempts loading data', () async {
      detailsRepo.failWithGeneric = true;
      container.listen(placeDetailsViewModelProvider('philae'), (_, _) {});
      await Future<void>.delayed(Duration.zero);

      var state = container.read(placeDetailsViewModelProvider('philae'));
      expect(state.hasError, isTrue);

      // Fix failure and retry
      detailsRepo.failWithGeneric = false;
      await container
          .read(placeDetailsViewModelProvider('philae').notifier)
          .retry();

      state = container.read(placeDetailsViewModelProvider('philae'));
      expect(state.hasValue, isTrue);
      expect(state.value?.nameEn, 'Philae Temple');
    });

    test('toggleBookmark toggles state to saved on success', () async {
      container.listen(placeDetailsViewModelProvider('philae'), (_, _) {});
      await Future<void>.delayed(Duration.zero);

      final success = await container
          .read(placeDetailsViewModelProvider('philae').notifier)
          .toggleBookmark();

      expect(success, isTrue);
      expect(placesRepo.lastSavedState, isTrue);
      final current = container.read(placeDetailsViewModelProvider('philae')).value;
      expect(current?.isBookmarked, isTrue);
    });

    test('toggleBookmark preserves previous state on repository failure', () async {
      container.listen(placeDetailsViewModelProvider('philae'), (_, _) {});
      await Future<void>.delayed(Duration.zero);

      placesRepo.failBookmark = true;
      final success = await container
          .read(placeDetailsViewModelProvider('philae').notifier)
          .toggleBookmark();

      expect(success, isFalse);
      final current = container.read(placeDetailsViewModelProvider('philae')).value;
      expect(current?.isBookmarked, isFalse); // Preserved!
    });
  });
}
