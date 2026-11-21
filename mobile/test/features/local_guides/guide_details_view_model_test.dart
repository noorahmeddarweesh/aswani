import 'package:aswani/core/errors/app_exception.dart';
import 'package:aswani/core/errors/failure.dart';
import 'package:aswani/core/result/result.dart';
import 'package:aswani/features/local_guides/domain/entities/guide.dart';
import 'package:aswani/features/local_guides/domain/entities/guide_application.dart';
import 'package:aswani/features/local_guides/domain/entities/guide_enums.dart';
import 'package:aswani/features/local_guides/domain/entities/guide_request.dart';
import 'package:aswani/features/local_guides/domain/entities/page_meta.dart';
import 'package:aswani/features/local_guides/domain/repositories/local_guides_repository.dart';
import 'package:aswani/features/local_guides/local_guides_providers.dart';
import 'package:aswani/features/local_guides/presentation/viewmodels/guide_details_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLocalGuidesRepository implements LocalGuidesRepository {
  _FakeLocalGuidesRepository({this.guideToReturn, this.failureToReturn});

  final Guide? guideToReturn;
  final Failure? failureToReturn;

  @override
  Future<Result<Guide>> getGuide(String id) async {
    if (failureToReturn != null) {
      return Result.failure(failureToReturn!);
    }
    if (guideToReturn != null && guideToReturn!.id == id) {
      return Result.success(guideToReturn!);
    }
    return Result.failure(
      Failure.fromException(
        const AppException(
          code: 'GUIDE_NOT_FOUND',
          statusCode: 404,
          message: 'Guide not found',
        ),
      ),
    );
  }

  @override
  Future<Result<PagedList<Guide>>> getGuides({
    GuideSpecialty? specialty,
    String? query,
    int page = 1,
    int limit = 20,
  }) async => throw UnimplementedError();

  @override
  Future<Result<GuideRequestResult>> createGuideRequest(
    GuideRequestCreate request,
  ) async => throw UnimplementedError();

  @override
  Future<Result<PagedList<GuideRequestItem>>> getGuideRequestsMine({
    int page = 1,
    int limit = 20,
  }) async => throw UnimplementedError();

  @override
  Future<Result<GuideApplicationResult>> createGuideApplication(
    GuideApplicationCreate application,
  ) async => throw UnimplementedError();
}

void main() {
  const sampleGuide = Guide(
    id: 'youssef-el-nuby',
    fullName: 'Youssef El Nuby',
    photo: 'assets/images/places/philae_temple.jpg',
    city: 'Aswan',
    tagline: 'Nubian stories',
    languages: [GuideLanguage.ar, GuideLanguage.en],
    specialties: [
      GuideSpecialty.nubianCulture,
      GuideSpecialty.historicalSites,
      GuideSpecialty.localExperiences,
    ],
    bio: 'Passionate about local stories, Nubian architecture, and Nile experiences.',
    durations: [
      GuideDuration.fewHours,
      GuideDuration.oneDay,
      GuideDuration.multipleDays,
    ],
    isFeatured: true,
    isVerified: false,
  );

  group('guideDetailsProvider', () {
    test('loads guide successfully when ID exists', () async {
      final fakeRepo = _FakeLocalGuidesRepository(guideToReturn: sampleGuide);
      final container = ProviderContainer(
        overrides: [localGuidesRepositoryProvider.overrideWithValue(fakeRepo)],
      );
      addTearDown(container.dispose);
      container.listen(guideDetailsProvider('youssef-el-nuby'), (_, _) {});

      final guide = await container.read(
        guideDetailsProvider('youssef-el-nuby').future,
      );

      expect(guide.id, 'youssef-el-nuby');
      expect(guide.fullName, 'Youssef El Nuby');
      expect(guide.city, 'Aswan');
      expect(guide.languages, [GuideLanguage.ar, GuideLanguage.en]);
      expect(guide.specialties.length, 3);
      expect(guide.durations.length, 3);
      expect(guide.isVerified, isFalse);
    });

    test('throws Failure when guide ID is not found (404)', () async {
      final fakeRepo = _FakeLocalGuidesRepository();
      final container = ProviderContainer(
        overrides: [localGuidesRepositoryProvider.overrideWithValue(fakeRepo)],
      );
      addTearDown(container.dispose);
      container.listen(guideDetailsProvider('unknown-id'), (_, _) {});

      await Future<void>.delayed(Duration.zero);

      final state = container.read(guideDetailsProvider('unknown-id'));
      expect(state.hasError, isTrue);
      expect(
        state.error,
        isA<Failure>().having((f) => f.code, 'code', 'GUIDE_NOT_FOUND'),
      );
    });

    test('throws Failure when repository encounters server error', () async {
      final fakeRepo = _FakeLocalGuidesRepository(
        failureToReturn: Failure.fromException(
          const AppException(
            code: 'SERVER_ERROR',
            statusCode: 500,
            message: 'Server error',
          ),
        ),
      );
      final container = ProviderContainer(
        overrides: [localGuidesRepositoryProvider.overrideWithValue(fakeRepo)],
      );
      addTearDown(container.dispose);
      container.listen(guideDetailsProvider('any-id'), (_, _) {});

      await Future<void>.delayed(Duration.zero);

      final state = container.read(guideDetailsProvider('any-id'));
      expect(state.hasError, isTrue);
      expect(
        state.error,
        isA<Failure>().having((f) => f.code, 'code', 'SERVER_ERROR'),
      );
    });
  });
}
