import 'package:aswani/core/l10n/generated/app_localizations.dart';
import 'package:aswani/core/result/result.dart';
import 'package:aswani/core/theme/app_theme.dart';
import 'package:aswani/features/local_guides/domain/entities/page_meta.dart';
import 'package:aswani/features/places/domain/entities/place.dart';
import 'package:aswani/features/places/domain/entities/place_details.dart';
import 'package:aswani/features/places/domain/entities/place_report.dart';
import 'package:aswani/features/places/domain/repositories/place_details_repository.dart';
import 'package:aswani/features/places/place_details_providers.dart';
import 'package:aswani/features/places/presentation/screens/place_report_details_screen.dart';
import 'package:aswani/features/places/presentation/screens/place_report_reason_screen.dart';
import 'package:aswani/features/places/presentation/screens/place_report_submitted_screen.dart';
import 'package:aswani/features/places/presentation/widgets/report_photo_picker_box.dart';
import 'package:aswani/features/places/presentation/widgets/report_place_summary_card.dart';
import 'package:aswani/features/places/presentation/widgets/report_reason_option_card.dart';
import 'package:aswani/features/places/presentation/widgets/report_timeline_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

class _FakeReportRepo implements PlaceDetailsRepository {
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
    aboutEn: 'Archaeological complex on an island.',
    aboutAr: 'مجمع أثري على جزيرة.',
    images: ['assets/images/places/philae_temple.jpg'],
    facts: [],
  );

  @override
  Future<Result<PlaceDetails>> getPlaceDetails(String id) async =>
      const Result.success(sampleDetails);

  @override
  Future<Result<PlaceReportResult>> createPlaceReport(
    PlaceReportCreate report,
  ) async => const Result.success(
    PlaceReportResult(id: 'rep-456', status: 'pending', pointsPending: 25),
  );

  @override
  Future<Result<PagedList<PlaceReportItem>>> getPlaceReportsMine({
    int page = 1,
    int limit = 20,
  }) async => throw UnimplementedError();
}

Widget buildTestApp({
  required Widget child,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: [
      placeDetailsRepositoryProvider.overrideWithValue(_FakeReportRepo()),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: child,
    ),
  );
}

void main() {
  group('PlaceReportReasonScreen (Screen 9)', () {
    testWidgets('renders all reasons and selects option to continue', (
      tester,
    ) async {
      reduceMotion(tester);
      tester.view.physicalSize = const Size(390 * 3, 1000 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      PlaceReportReason? selectedReason;
      var backTapped = false;

      await tester.pumpWidget(
        buildTestApp(
          child: PlaceReportReasonScreen(
            placeId: 'philae',
            place: _FakeReportRepo.sampleDetails,
            onBackTap: () => backTapped = true,
            onContinue: (reason) => selectedReason = reason,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header checks
      expect(find.text('Report a place'), findsOneWidget);
      expect(find.text('HELP IMPROVE THE GUIDE'), findsOneWidget);
      expect(find.text('What needs updating?'), findsOneWidget);
      expect(
        find.text('Choose the reason that best matches what you found.'),
        findsOneWidget,
      );

      // 6 Reasons
      expect(find.byType(ReportReasonOptionCard), findsNWidgets(6));
      expect(find.text('Place does not exist'), findsOneWidget);
      expect(find.text('Permanently closed'), findsOneWidget);
      expect(find.text('Temporarily closed'), findsOneWidget);
      expect(find.text('Incorrect location'), findsOneWidget);
      expect(find.text('Incorrect information'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(backTapped, isTrue);

      // Tap on a reason card
      await tester.tap(find.text('Incorrect information'));
      await tester.pumpAndSettle();

      // Tap continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(selectedReason, PlaceReportReason.incorrectInformation);
    });
  });

  group('PlaceReportDetailsScreen (Screen 10)', () {
    testWidgets('renders summary, handles input and submits report', (
      tester,
    ) async {
      reduceMotion(tester);
      tester.view.physicalSize = const Size(390 * 3, 1000 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      PlaceReportResult? submittedResult;

      await tester.pumpWidget(
        buildTestApp(
          child: PlaceReportDetailsScreen(
            placeId: 'philae',
            place: _FakeReportRepo.sampleDetails,
            initialReason: PlaceReportReason.incorrectLocation,
            onSubmitSuccess: (res) => submittedResult = res,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Summary Card
      expect(find.byType(ReportPlaceSummaryCard), findsOneWidget);
      expect(find.text('SELECTED PLACE'), findsOneWidget);
      expect(find.text('Philae Temple'), findsOneWidget);
      expect(find.text('Agilkia Island, Aswan'), findsOneWidget);

      // Form Elements
      expect(find.text('Tell us what you found *'), findsOneWidget);
      expect(find.byType(ReportPhotoPickerBox), findsOneWidget);
      expect(find.text('Add supporting photo'), findsOneWidget);
      expect(find.text('Every report is reviewed'), findsOneWidget);
      expect(
        find.text('Points are awarded only after acceptance.'),
        findsOneWidget,
      );

      // Enter Details text
      await tester.enterText(
        find.byType(TextField),
        'The pin is shifted to the northern side of the island.',
      );
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.text('Submit report'));
      await tester.pumpAndSettle();

      expect(submittedResult, isNotNull);
      expect(submittedResult?.id, 'rep-456');
      expect(submittedResult?.pointsPending, 25);
    });
  });

  group('PlaceReportSubmittedScreen (Screen 11)', () {
    testWidgets(
      'renders confirmation, points card, timeline, and done button',
      (tester) async {
        reduceMotion(tester);
        tester.view.physicalSize = const Size(390 * 3, 1000 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        var doneTapped = false;

        await tester.pumpWidget(
          buildTestApp(
            child: PlaceReportSubmittedScreen(
              result: const PlaceReportResult(
                id: 'rep-456',
                status: 'pending',
                pointsPending: 25,
              ),
              onDoneTap: () => doneTapped = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Header
        expect(find.text('UNDER REVIEW'), findsOneWidget);
        expect(
          find.text('Thank you for helping keep ASWANI accurate'),
          findsOneWidget,
        );
        expect(
          find.text(
            'Your report is with the review team. Points are awarded only if the information is accepted.',
          ),
          findsOneWidget,
        );

        // Points card
        expect(find.text('+25'), findsOneWidget);
        expect(find.text('points pending'), findsOneWidget);
        expect(find.text('Pending review'), findsOneWidget);

        // Timeline
        expect(find.byType(ReportTimelineIndicator), findsOneWidget);
        expect(
          find.text('Submitted • Under review • Points after acceptance'),
          findsOneWidget,
        );

        // Tap Done
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();
        expect(doneTapped, isTrue);
      },
    );

    testWidgets(
      'Arabic RTL renders Arabic copy correctly across report screens',
      (tester) async {
        reduceMotion(tester);
        tester.view.physicalSize = const Size(390 * 3, 1000 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        // Screen 9 in Arabic
        await tester.pumpWidget(
          buildTestApp(
            locale: const Locale('ar'),
            child: const PlaceReportReasonScreen(
              placeId: 'philae',
              place: _FakeReportRepo.sampleDetails,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('الإبلاغ عن مكان'), findsOneWidget);
        expect(find.text('ساعد في تحسين الدليل'), findsOneWidget);
        expect(find.text('ما الذي يحتاج إلى تحديث؟'), findsOneWidget);
        expect(find.text('المعلومات غير صحيحة'), findsOneWidget);
        expect(find.text('الموقع غير صحيح'), findsOneWidget);
        expect(find.text('متابعة'), findsOneWidget);

        // Screen 11 in Arabic
        await tester.pumpWidget(
          buildTestApp(
            locale: const Locale('ar'),
            child: const PlaceReportSubmittedScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('قيد المراجعة'), findsNWidgets(2)); // eyebrow + badge
        expect(
          find.text('شكرًا لمساعدتك في الحفاظ على دقة أسواني'),
          findsOneWidget,
        );
        expect(find.text('نقطة معلقة'), findsOneWidget);
        expect(
          find.text('تم الإرسال • قيد المراجعة • نقاط بعد القبول'),
          findsOneWidget,
        );
        expect(find.text('تم'), findsOneWidget);
      },
    );
  });
}
