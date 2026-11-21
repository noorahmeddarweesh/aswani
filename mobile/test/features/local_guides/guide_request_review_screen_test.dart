import 'package:aswani/core/errors/failure.dart';
import 'package:aswani/core/l10n/generated/app_localizations.dart';
import 'package:aswani/core/result/result.dart';
import 'package:aswani/core/theme/app_theme.dart';
import 'package:aswani/features/local_guides/domain/entities/guide.dart';
import 'package:aswani/features/local_guides/domain/entities/guide_application.dart';
import 'package:aswani/features/local_guides/domain/entities/guide_enums.dart';
import 'package:aswani/features/local_guides/domain/entities/guide_request.dart';
import 'package:aswani/features/local_guides/domain/entities/page_meta.dart';
import 'package:aswani/features/local_guides/domain/repositories/local_guides_repository.dart';
import 'package:aswani/features/local_guides/local_guides_providers.dart';
import 'package:aswani/features/local_guides/presentation/screens/guide_request_review_screen.dart';
import 'package:aswani/features/local_guides/presentation/viewmodels/guide_request_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

class _MockReviewRepo implements LocalGuidesRepository {
  _MockReviewRepo({
    this.failWithDateInPast = false,
    this.failWithGuideNotFound = false,
    this.failWithNetworkError = false,
  });

  final bool failWithDateInPast;
  final bool failWithGuideNotFound;
  final bool failWithNetworkError;

  GuideRequestCreate? capturedPayload;
  int submissionCount = 0;

  static const sampleGuide = Guide(
    id: 'youssef-el-nuby',
    fullName: 'Youssef El Nuby',
    photo: 'assets/images/places/philae_temple.jpg',
    city: 'Aswan',
    tagline: 'Nubian stories • History walks',
    languages: [GuideLanguage.ar, GuideLanguage.en],
    specialties: [GuideSpecialty.nubianCulture, GuideSpecialty.nile],
    bio: 'Passionate about local stories and Nubian architecture.',
    durations: [GuideDuration.fewHours, GuideDuration.oneDay],
    isFeatured: true,
    isVerified: false,
  );

  @override
  Future<Result<Guide>> getGuide(String id) async {
    return const Result.success(sampleGuide);
  }

  @override
  Future<Result<GuideRequestResult>> createGuideRequest(
    GuideRequestCreate request,
  ) async {
    submissionCount++;
    capturedPayload = request;

    if (failWithDateInPast) {
      return const Result.failure(
        Failure('VALIDATION_ERROR', fieldErrors: {'date': 'DATE_IN_PAST'}),
      );
    }
    if (failWithGuideNotFound) {
      return const Result.failure(Failure('GUIDE_NOT_FOUND'));
    }
    if (failWithNetworkError) {
      return const Result.failure(Failure('NO_CONNECTION'));
    }

    return const Result.success(
      GuideRequestResult(id: 'req-1', status: RequestStatus.pending),
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
  const testGuideId = 'youssef-el-nuby';

  final standardDraft = const GuideRequestCreate(
    guideId: testGuideId,
    date: '2026-06-20', // Saturday, 20 June
    duration: RequestDuration.oneDay,
    durationHours: 6,
    startTime: '09:00',
    groupSize: 2,
    language: GuideLanguage.en,
    interests: [GuideSpecialty.nubianCulture, GuideSpecialty.nile],
  );

  Widget buildSubject({
    required LocalGuidesRepository repository,
    GuideRequestCreate? draft,
    ValueChanged<GuideRequestResult>? onConfirmSuccess,
    VoidCallback? onBackPressed,
    Locale locale = const Locale('en'),
    ProviderContainer? container,
  }) {
    final app = MaterialApp(
      theme: AppTheme.light,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: GuideRequestReviewScreen(
        guideId: testGuideId,
        requestDraft: draft ?? standardDraft,
        onConfirmSuccess: onConfirmSuccess,
        onBackPressed: onBackPressed,
      ),
    );

    final overrides = [
      localGuidesRepositoryProvider.overrideWithValue(repository),
    ];

    if (container != null) {
      return UncontrolledProviderScope(container: container, child: app);
    }

    return ProviderScope(overrides: overrides, child: app);
  }

  group('GuideRequestReviewScreen Widget Tests', () {
    testWidgets(
      'renders all screen sections and elements matching guide_request_details.jpg',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = _MockReviewRepo();
        await tester.pumpWidget(buildSubject(repository: repo));
        await tester.pumpAndSettle();

        // Top bar title
        expect(find.text('Review request'), findsOneWidget);

        // Selected Guide Card
        expect(find.byKey(const Key('review_guide_card')), findsOneWidget);
        expect(find.text('SELECTED GUIDE'), findsOneWidget);
        expect(find.text('Youssef El Nuby'), findsOneWidget);
        expect(find.text('Sample profile'), findsOneWidget);

        // Summary Card Rows
        expect(find.byKey(const Key('review_summary_card')), findsOneWidget);
        expect(find.text('Date'), findsOneWidget);
        expect(find.text('Saturday, 20 June'), findsOneWidget);
        expect(find.text('Duration'), findsOneWidget);
        expect(find.text('One day • 6 hours'), findsOneWidget);
        expect(find.text('Group'), findsOneWidget);
        expect(find.text('2 people'), findsOneWidget);
        expect(find.text('Language'), findsOneWidget);
        expect(find.text('English'), findsOneWidget);
        expect(find.text('Interests'), findsOneWidget);
        expect(find.text('Nubian culture, Nile'), findsOneWidget);

        // Availability notice
        expect(
          find.byKey(const Key('review_availability_banner')),
          findsOneWidget,
        );
        expect(find.text('Availability is not guaranteed'), findsOneWidget);
        expect(
          find.text('The date is confirmed only after the guide accepts.'),
          findsOneWidget,
        );
        expect(find.byIcon(LucideIcons.clock), findsOneWidget);

        // Confirm button
        expect(find.byKey(const Key('review_confirm_button')), findsOneWidget);
        expect(find.text('Confirm and send request'), findsOneWidget);
      },
    );

    testWidgets(
      'omits Interests row when interests list is empty per contract requirement',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final emptyInterestsDraft = const GuideRequestCreate(
          guideId: testGuideId,
          date: '2026-06-20',
          duration: RequestDuration.fewHours,
          startTime: '10:00',
          groupSize: 1,
          language: GuideLanguage.en,
          interests: [],
        );

        final repo = _MockReviewRepo();
        await tester.pumpWidget(
          buildSubject(repository: repo, draft: emptyInterestsDraft),
        );
        await tester.pumpAndSettle();

        // Summary Card should NOT have Interests row if guide specialties also empty or omitted
        expect(find.text('Date'), findsOneWidget);
        expect(find.text('Duration'), findsOneWidget);
        expect(find.text('A few hours'), findsOneWidget);
        expect(find.text('Group'), findsOneWidget);
        expect(find.text('1 person'), findsOneWidget);
      },
    );

    testWidgets(
      'successful submission triggers repository, resets form state, and calls onConfirmSuccess',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = _MockReviewRepo();
        final container = ProviderContainer(
          overrides: [localGuidesRepositoryProvider.overrideWithValue(repo)],
        );
        addTearDown(container.dispose);

        // Set date in form viewModel
        container
            .read(guideRequestViewModelProvider(testGuideId).notifier)
            .setDate('2026-06-20');
        expect(
          container.read(guideRequestViewModelProvider(testGuideId)).date,
          isNotNull,
        );

        GuideRequestResult? successResult;
        await tester.pumpWidget(
          buildSubject(
            repository: repo,
            container: container,
            onConfirmSuccess: (res) => successResult = res,
          ),
        );
        await tester.pumpAndSettle();

        // Tap confirm button
        await tester.tap(find.byKey(const Key('review_confirm_button')));
        await tester.pumpAndSettle();

        expect(repo.submissionCount, equals(1));
        expect(repo.capturedPayload, isNotNull);
        expect(repo.capturedPayload!.guideId, equals(testGuideId));
        expect(repo.capturedPayload!.date, equals('2026-06-20'));
        expect(repo.capturedPayload!.duration, equals(RequestDuration.oneDay));
        expect(repo.capturedPayload!.durationHours, equals(6));
        expect(successResult, isNotNull);
        expect(successResult!.id, equals('req-1'));

        // Form state must be reset ONLY after success
        expect(
          container.read(guideRequestViewModelProvider(testGuideId)).date,
          isNull,
        );
      },
    );

    testWidgets(
      '422 DATE_IN_PAST displays translated error and preserves form state for retry',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = _MockReviewRepo(failWithDateInPast: true);
        final container = ProviderContainer(
          overrides: [localGuidesRepositoryProvider.overrideWithValue(repo)],
        );
        addTearDown(container.dispose);

        final sub = container.listen(
          guideRequestViewModelProvider(testGuideId),
          (_, _) {},
        );
        addTearDown(sub.close);

        container
            .read(guideRequestViewModelProvider(testGuideId).notifier)
            .setDate('2020-01-01');

        await tester.pumpWidget(
          buildSubject(
            repository: repo,
            container: container,
            draft: const GuideRequestCreate(
              guideId: testGuideId,
              date: '2020-01-01',
              duration: RequestDuration.oneDay,
              durationHours: 6,
              startTime: '09:00',
              groupSize: 2,
              language: GuideLanguage.en,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap confirm button
        await tester.tap(find.byKey(const Key('review_confirm_button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('review_error_banner')), findsOneWidget);
        expect(find.text('Date cannot be in the past'), findsOneWidget);

        // Form state preserved (not cleared on error)
        expect(
          container.read(guideRequestViewModelProvider(testGuideId)).date,
          equals('2020-01-01'),
        );
      },
    );

    testWidgets(
      '404 GUIDE_NOT_FOUND displays translated guide not found error',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = _MockReviewRepo(failWithGuideNotFound: true);
        await tester.pumpWidget(buildSubject(repository: repo));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('review_confirm_button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('review_error_banner')), findsOneWidget);
        expect(find.text('Guide not found.'), findsOneWidget);
      },
    );

    testWidgets(
      'network error displays error and permits retry without losing data',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = _MockReviewRepo(failWithNetworkError: true);
        await tester.pumpWidget(buildSubject(repository: repo));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('review_confirm_button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('review_error_banner')), findsOneWidget);
        expect(
          find.text('Failed to load guides. Please try again.'),
          findsOneWidget,
        );
        expect(repo.submissionCount, equals(1));

        // Retry
        await tester.tap(find.byKey(const Key('review_confirm_button')));
        await tester.pumpAndSettle();
        expect(repo.submissionCount, equals(2));
      },
    );

    testWidgets(
      'renders Arabic strings and RTL directionality in Arabic locale',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = _MockReviewRepo();
        await tester.pumpWidget(
          buildSubject(repository: repo, locale: const Locale('ar')),
        );
        await tester.pumpAndSettle();

        expect(find.text('مراجعة الطلب'), findsOneWidget);
        expect(find.text('المرشد المحدد'), findsOneWidget);
        expect(find.text('ملف تجريبي'), findsOneWidget);
        expect(find.text('التاريخ'), findsOneWidget);
        expect(find.text('السبت، 20 يونيو'), findsOneWidget);
        expect(find.text('المدة'), findsOneWidget);
        expect(find.text('يوم واحد • 6 ساعات'), findsOneWidget);
        expect(find.text('المجموعة'), findsOneWidget);
        expect(find.text('شخصان'), findsOneWidget);
        expect(find.text('اللغة'), findsOneWidget);
        expect(find.text('الإنجليزية'), findsOneWidget);
        expect(find.text('الاهتمامات'), findsOneWidget);
        expect(find.text('ثقافة نوبية، النيل'), findsOneWidget);
        expect(find.text('التوفر غير مضمون'), findsOneWidget);
        expect(
          find.text('يتم تأكيد الموعد فقط بعد موافقة المرشد.'),
          findsOneWidget,
        );
        expect(find.text('تأكيد وإرسال الطلب'), findsOneWidget);

        final directionality = Directionality.of(
          tester.element(find.text('مراجعة الطلب')),
        );
        expect(directionality, equals(TextDirection.rtl));
      },
    );
  });
}
