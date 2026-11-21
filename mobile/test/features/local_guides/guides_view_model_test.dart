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
import 'package:aswani/features/local_guides/presentation/viewmodels/guides_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLocalGuidesRepository implements LocalGuidesRepository {
  _FakeLocalGuidesRepository({this.shouldFail = false});

  final bool shouldFail;
  int getGuidesCallCount = 0;
  GuideSpecialty? lastSpecialty;
  String? lastQuery;
  int lastPage = 1;

  static const sampleGuides = [
    Guide(
      id: 'youssef',
      fullName: 'Youssef El Nuby',
      photo: 'youssef.jpg',
      city: 'Aswan',
      tagline: 'Nubian stories',
      languages: [GuideLanguage.ar, GuideLanguage.en],
      specialties: [GuideSpecialty.nubianCulture],
      bio: 'Bio',
      durations: [GuideDuration.fewHours, GuideDuration.oneDay],
      isFeatured: true,
      isVerified: false,
    ),
    Guide(
      id: 'mariam',
      fullName: 'Mariam Ahmed',
      photo: 'mariam.jpg',
      city: 'Aswan',
      tagline: 'Local experiences',
      languages: [GuideLanguage.ar],
      specialties: [GuideSpecialty.nubianCulture],
      bio: 'Bio',
      durations: [GuideDuration.oneDay],
      isFeatured: false,
      isVerified: false,
    ),
  ];

  @override
  Future<Result<PagedList<Guide>>> getGuides({
    GuideSpecialty? specialty,
    String? query,
    int page = 1,
    int limit = 20,
  }) async {
    getGuidesCallCount++;
    lastSpecialty = specialty;
    lastQuery = query;
    lastPage = page;

    if (shouldFail) {
      return Result.failure(
        Failure.fromException(
          const AppException(
            code: 'SERVER_ERROR',
            message: 'Failed to fetch guides',
          ),
        ),
      );
    }

    return const Result.success(
      PagedList<Guide>(
        data: sampleGuides,
        meta: PageMeta(page: 1, limit: 20, total: 2, totalPages: 1),
      ),
    );
  }

  @override
  Future<Result<Guide>> getGuide(String id) async => throw UnimplementedError();

  @override
  Future<Result<GuideRequestResult>> createGuideRequest(
    GuideRequestCreate request,
  ) async =>
      throw UnimplementedError();

  @override
  Future<Result<PagedList<GuideRequestItem>>> getGuideRequestsMine({
    int page = 1,
    int limit = 20,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Result<GuideApplicationResult>> createGuideApplication(
    GuideApplicationCreate application,
  ) async =>
      throw UnimplementedError();
}

void main() {
  group('GuidesFilterViewModel', () {
    test('initial state defaults to Nubian culture and empty query', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(guidesFilterProvider, (_, _) {});

      final filter = container.read(guidesFilterProvider);
      expect(filter.specialty, GuideSpecialty.nubianCulture);
      expect(filter.query, isEmpty);
    });

    test('toggleSpecialty switches to new specialty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(guidesFilterProvider, (_, _) {});

      final vm = container.read(guidesFilterProvider.notifier);
      vm.toggleSpecialty(GuideSpecialty.nile);

      expect(
        container.read(guidesFilterProvider).specialty,
        GuideSpecialty.nile,
      );
    });

    test('toggleSpecialty clears filter when tapping active specialty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(guidesFilterProvider, (_, _) {});

      final vm = container.read(guidesFilterProvider.notifier);
      expect(
        container.read(guidesFilterProvider).specialty,
        GuideSpecialty.nubianCulture,
      );

      // Tapping the active specialty clears it
      vm.toggleSpecialty(GuideSpecialty.nubianCulture);
      expect(container.read(guidesFilterProvider).specialty, isNull);
    });

    test('debounces search by 300ms', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(guidesFilterProvider, (_, _) {});

      final vm = container.read(guidesFilterProvider.notifier);
      vm.onSearchChanged('Mariam');

      // Immediate check should still be empty
      expect(container.read(guidesFilterProvider).query, isEmpty);

      // Awaiting 350ms triggers the debounce
      await Future<void>.delayed(const Duration(milliseconds: 350));
      expect(container.read(guidesFilterProvider).query, 'Mariam');
    });

    test('searchImmediate updates query without debounce', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(guidesFilterProvider, (_, _) {});

      final vm = container.read(guidesFilterProvider.notifier);
      vm.searchImmediate('Ahmed');

      expect(container.read(guidesFilterProvider).query, 'Ahmed');
    });
  });

  group('GuidesListViewModel', () {
    test('loads initial guides with default Nubian culture specialty', () async {
      final fakeRepo = _FakeLocalGuidesRepository();
      final container = ProviderContainer(
        overrides: [
          localGuidesRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);
      container.listen(guidesListProvider, (_, _) {});

      final state = await container.read(guidesListProvider.future);
      expect(state.guides.length, 2);
      expect(fakeRepo.lastSpecialty, GuideSpecialty.nubianCulture);
      expect(state.featuredGuide?.id, 'youssef');
      expect(state.suggestedGuides.length, 1);
      expect(state.suggestedGuides.first.id, 'mariam');
    });

    test('emits error state on repository failure and supports retry', () async {
      final fakeRepo = _FakeLocalGuidesRepository(shouldFail: true);
      final container = ProviderContainer(
        overrides: [
          localGuidesRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);
      container.listen(guidesListProvider, (_, _) {});

      // Allow async notifier build to complete
      await Future<void>.delayed(Duration.zero);

      final state = container.read(guidesListProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<Failure>());
    });
  });
}
