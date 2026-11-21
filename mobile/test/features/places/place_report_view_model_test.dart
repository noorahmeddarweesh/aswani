import 'package:aswani/core/errors/app_exception.dart';
import 'package:aswani/core/errors/failure.dart';
import 'package:aswani/core/result/result.dart';
import 'package:aswani/features/local_guides/domain/entities/page_meta.dart';
import 'package:aswani/features/places/domain/entities/place.dart';
import 'package:aswani/features/places/domain/entities/place_details.dart';
import 'package:aswani/features/places/domain/entities/place_report.dart';
import 'package:aswani/features/places/domain/repositories/place_details_repository.dart';
import 'package:aswani/features/places/place_details_providers.dart';
import 'package:aswani/features/places/presentation/viewmodels/place_report_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_photos.dart';

class _FakePlaceDetailsRepo implements PlaceDetailsRepository {
  _FakePlaceDetailsRepo()
    : failWithValidation = false,
      failWithNotFound = false;

  bool failWithNotFound;
  bool failWithValidation;

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
    aboutEn: 'Sample description',
    aboutAr: 'وصف تجريبي',
    images: ['assets/images/places/philae_temple.jpg'],
    facts: [],
  );

  @override
  Future<Result<PlaceDetails>> getPlaceDetails(String id) async {
    if (failWithNotFound) {
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
    return const Result.success(sampleDetails);
  }

  @override
  Future<Result<PlaceReportResult>> createPlaceReport(
    PlaceReportCreate report,
  ) async {
    if (failWithNotFound) {
      return Result.failure(
        Failure.fromException(
          const AppException(
            code: ErrorCodes.placeNotFound,
            statusCode: 404,
            message: 'Place not found for report',
          ),
        ),
      );
    }
    if (failWithValidation) {
      return Result.failure(
        Failure.fromException(
          const AppException(
            code: ErrorCodes.validation,
            statusCode: 422,
            details: {'details': 'VALIDATION_ERROR'},
            message: 'Validation failed',
          ),
        ),
      );
    }
    return const Result.success(
      PlaceReportResult(id: 'rep-123', status: 'pending', pointsPending: 25),
    );
  }

  @override
  Future<Result<PagedList<PlaceReportItem>>> getPlaceReportsMine({
    int page = 1,
    int limit = 20,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  group('PlaceReportViewModel', () {
    late _FakePlaceDetailsRepo repo;
    late ProviderContainer container;

    setUp(() {
      repo = _FakePlaceDetailsRepo();
      container = ProviderContainer(
        overrides: [placeDetailsRepositoryProvider.overrideWithValue(repo)],
      );
    });

    tearDown(() => container.dispose());

    test('initial state defaults correctly', () {
      final state = container.read(placeReportViewModelProvider);
      expect(state.placeId, isEmpty);
      expect(state.place, isNull);
      expect(state.reason, isNull);
      expect(state.details, isEmpty);
      expect(state.photo, isNull);
      expect(state.canContinueFromReason, isFalse);
      expect(state.canSubmit, isFalse);
      expect(state.isSubmitting, isFalse);
    });

    test('init loads place details when place is not supplied', () async {
      final notifier = container.read(placeReportViewModelProvider.notifier);
      await notifier.init('philae');

      final state = container.read(placeReportViewModelProvider);
      expect(state.placeId, 'philae');
      expect(state.place?.nameEn, 'Philae Temple');
    });

    test('selectReason updates reason and allows continuation', () {
      final notifier = container.read(placeReportViewModelProvider.notifier);
      notifier.selectReason(PlaceReportReason.incorrectInformation);

      final state = container.read(placeReportViewModelProvider);
      expect(state.reason, PlaceReportReason.incorrectInformation);
      expect(state.canContinueFromReason, isTrue);
    });

    test('setDetails validates 1000 char limit', () {
      final notifier = container.read(placeReportViewModelProvider.notifier);
      notifier.setDetails('Normal details');

      var state = container.read(placeReportViewModelProvider);
      expect(state.details, 'Normal details');
      expect(state.detailsError, isNull);

      final tooLong = 'A' * 1001;
      notifier.setDetails(tooLong);
      state = container.read(placeReportViewModelProvider);
      expect(state.detailsError, 'DETAILS_TOO_LONG');
    });

    test('setPhoto validates file extension and size', () {
      final notifier = container.read(placeReportViewModelProvider.notifier);

      // Valid extension
      notifier.setPhoto(testPhoto('photo.jpg'));
      var state = container.read(placeReportViewModelProvider);
      expect(state.photo?.name, 'photo.jpg');
      expect(state.photoError, isNull);

      // Unsupported extension
      notifier.setPhoto(testPhoto('photo.pdf'));
      state = container.read(placeReportViewModelProvider);
      expect(state.photoError, 'UNSUPPORTED_FILE_TYPE');

      // File too large
      notifier.setPhoto(testPhoto('my_too_large_photo.png'));
      state = container.read(placeReportViewModelProvider);
      expect(state.photoError, 'FILE_TOO_LARGE');

      // Remove photo
      notifier.removePhoto();
      state = container.read(placeReportViewModelProvider);
      expect(state.photo, isNull);
      expect(state.photoError, isNull);
    });

    test('submit succeeds on valid form', () async {
      final notifier = container.read(placeReportViewModelProvider.notifier);
      await notifier.init('philae');
      notifier.selectReason(PlaceReportReason.incorrectLocation);
      notifier.setDetails('Coordinates are shifted 200m south.');

      final success = await notifier.submit();

      expect(success, isTrue);
      final state = container.read(placeReportViewModelProvider);
      expect(state.isSubmitting, isFalse);
      expect(state.result?.id, 'rep-123');
      expect(state.result?.pointsPending, 25);
      expect(state.result?.status, 'pending');
    });

    test('submit fails when details are empty', () async {
      final notifier = container.read(placeReportViewModelProvider.notifier);
      await notifier.init('philae');
      notifier.selectReason(PlaceReportReason.notExist);

      final success = await notifier.submit();

      expect(success, isFalse);
      final state = container.read(placeReportViewModelProvider);
      expect(state.detailsError, 'DETAILS_REQUIRED');
    });

    test('submit handles 422 repository validation error', () async {
      repo.failWithValidation = true;
      final notifier = container.read(placeReportViewModelProvider.notifier);
      await notifier.init('philae');
      notifier.selectReason(PlaceReportReason.other);
      notifier.setDetails('Invalid details');

      final success = await notifier.submit();

      expect(success, isFalse);
      final state = container.read(placeReportViewModelProvider);
      expect(state.serverError, ErrorCodes.validation);
    });

    test('reset restores initial state', () {
      final notifier = container.read(placeReportViewModelProvider.notifier);
      notifier.selectReason(PlaceReportReason.other);
      notifier.setDetails('Details');
      notifier.reset();

      final state = container.read(placeReportViewModelProvider);
      expect(state.reason, isNull);
      expect(state.details, isEmpty);
    });
  });
}
