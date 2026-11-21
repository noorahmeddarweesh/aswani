import 'package:aswani/core/config/retry_policy.dart';
import 'package:aswani/core/errors/app_exception.dart';
import 'package:aswani/core/errors/failure.dart';
import 'package:aswani/core/l10n/generated/app_localizations.dart';
import 'package:aswani/core/result/result.dart';
import 'package:aswani/core/theme/app_theme.dart';
import 'package:aswani/features/local_guides/domain/entities/page_meta.dart';
import 'package:aswani/features/places/domain/entities/place.dart';
import 'package:aswani/features/places/domain/entities/place_details.dart';
import 'package:aswani/features/places/domain/entities/place_report.dart';
import 'package:aswani/features/places/domain/repositories/place_details_repository.dart';
import 'package:aswani/features/places/domain/repositories/places_repository.dart';
import 'package:aswani/features/places/place_details_providers.dart';
import 'package:aswani/features/places/places_providers.dart';
import 'package:aswani/features/places/presentation/screens/place_details_screen.dart';
import 'package:aswani/features/places/presentation/widgets/place_fact_card.dart';
import 'package:aswani/features/places/presentation/widgets/place_hero_carousel.dart';
import 'package:aswani/features/places/presentation/widgets/place_report_tile.dart';
import 'package:aswani/features/places/presentation/widgets/place_visiting_info_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

class _MockDetailsRepo implements PlaceDetailsRepository {
  _MockDetailsRepo({
    this.failWithNotFound = false,
    this.failWithGeneric = false,
    this.emptyFacts = false,
    this.emptyImages = false,
  });

  final bool failWithNotFound;
  final bool failWithGeneric;
  final bool emptyFacts;
  final bool emptyImages;

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
    if (failWithGeneric) {
      return const Result.failure(Failure.unknown);
    }

    return Result.success(
      PlaceDetails(
        place: samplePlace,
        locationEn: 'Agilkia Island, Aswan',
        locationAr: 'جزيرة أجيليكيا، أسوان',
        aboutEn: 'An archaeological complex on an island in the Nile. This prototype summary is illustrative.',
        aboutAr: 'مجمع أثري على جزيرة في النيل. هذا الملخص النموذجي توضيحي.',
        images: emptyImages
            ? const []
            : const [
                'assets/images/places/philae_temple.jpg',
                'assets/images/places/philae_temple.jpg',
              ],
        facts: emptyFacts
            ? const []
            : const [
                PlaceFact(
                  type: 'access',
                  labelEn: 'Boat access',
                  labelAr: 'الوصول بالقارب',
                ),
                PlaceFact(
                  type: 'hours',
                  labelEn: 'Check before visiting',
                  labelAr: 'تحقق قبل الزيارة',
                ),
              ],
      ),
    );
  }

  @override
  Future<Result<PlaceReportResult>> createPlaceReport(
    PlaceReportCreate report,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<PagedList<PlaceReportItem>>> getPlaceReportsMine({
    int page = 1,
    int limit = 20,
  }) async {
    throw UnimplementedError();
  }
}

class _MockPlacesRepo implements PlacesRepository {
  bool isBookmarked = false;

  @override
  Future<Result<List<Place>>> getPlaces({PlaceCategory? category}) async =>
      const Result.success([]);

  @override
  Future<Result<List<Place>>> getCurated() async => const Result.success([]);

  @override
  Future<Result<Place>> setBookmark(
    String placeId, {
    required bool saved,
  }) async {
    isBookmarked = saved;
    final updated = _MockDetailsRepo.samplePlace.copyWith(isBookmarked: saved);
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

Future<void> pumpScreen(
  WidgetTester tester, {
  String placeId = 'philae',
  bool failWithNotFound = false,
  bool failWithGeneric = false,
  bool emptyFacts = false,
  bool emptyImages = false,
  Locale locale = const Locale('en'),
  VoidCallback? onBackTap,
  VoidCallback? onShareTap,
  VoidCallback? onReportTap,
}) async {
  reduceMotion(tester);
  tester.view.physicalSize = const Size(390 * 3, 1000 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final detailsRepo = _MockDetailsRepo(
    failWithNotFound: failWithNotFound,
    failWithGeneric: failWithGeneric,
    emptyFacts: emptyFacts,
    emptyImages: emptyImages,
  );
  final placesRepo = _MockPlacesRepo();

  await tester.pumpWidget(
    ProviderScope(
      retry: noAutoRetry,
      overrides: [
        placeDetailsRepositoryProvider.overrideWithValue(detailsRepo),
        placesRepositoryProvider.overrideWithValue(placesRepo),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        home: PlaceDetailsScreen(
          placeId: placeId,
          onBackTap: onBackTap,
          onShareTap: onShareTap,
          onReportTap: onReportTap,
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('PlaceDetailsScreen', () {
    testWidgets(
      'renders all screen sections and content matching design spec',
      (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        // Hero carousel and counter
        expect(find.byType(PlaceHeroCarousel), findsOneWidget);
        expect(find.text('1 / 2'), findsOneWidget);

        // Gold Eyebrow & Title
        expect(find.text('HISTORICAL PLACE'), findsOneWidget);
        expect(find.text('Philae Temple'), findsOneWidget);

        // Location Row
        expect(find.byIcon(LucideIcons.mapPin), findsOneWidget);
        expect(find.text('Agilkia Island, Aswan'), findsOneWidget);

        // Key Fact Cards
        expect(find.byType(PlaceFactCard), findsNWidgets(2));
        expect(find.text('Boat access'), findsOneWidget);
        expect(find.text('Check before visiting'), findsOneWidget);
        expect(find.byIcon(LucideIcons.map), findsOneWidget);
        expect(find.byIcon(LucideIcons.clock), findsOneWidget);

        // About Section
        expect(find.text('About this place'), findsOneWidget);
        expect(
          find.textContaining(
            'An archaeological complex on an island in the Nile',
          ),
          findsOneWidget,
        );

        // Visiting Information Card
        expect(find.byType(PlaceVisitingInfoCard), findsOneWidget);
        expect(find.text('Visiting information'), findsOneWidget);
        expect(
          find.text('Unverified hours and prices are intentionally not shown.'),
          findsOneWidget,
        );

        // Report Tile
        expect(find.byType(PlaceReportTile), findsOneWidget);
        expect(
          find.text('See something inaccurate? Report it'),
          findsOneWidget,
        );
      },
    );

    testWidgets('tap callbacks for back, share, bookmark, and report trigger', (
      tester,
    ) async {
      var backTapped = false;
      var shareTapped = false;
      var reportTapped = false;

      await pumpScreen(
        tester,
        onBackTap: () => backTapped = true,
        onShareTap: () => shareTapped = true,
        onReportTap: () => reportTapped = true,
      );
      await tester.pumpAndSettle();

      // Tap Back button
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(backTapped, isTrue);

      // Tap Share button
      await tester.tap(find.byTooltip('Share'));
      await tester.pumpAndSettle();
      expect(shareTapped, isTrue);

      // Tap Bookmark button
      await tester.tap(find.byTooltip('Save place'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Remove bookmark'), findsOneWidget);

      // Scroll to report tile and tap
      final scrollable = find.descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        find.byType(PlaceReportTile),
        200,
        scrollable: scrollable,
      );
      await tester.tap(find.byType(PlaceReportTile));
      await tester.pumpAndSettle();
      expect(reportTapped, isTrue);
    });

    testWidgets('empty facts and empty images are handled gracefully', (
      tester,
    ) async {
      await pumpScreen(tester, emptyFacts: true, emptyImages: true);
      await tester.pumpAndSettle();

      // Should not crash, fact cards omitted
      expect(find.byType(PlaceFactCard), findsNothing);
      expect(find.text('Philae Temple'), findsOneWidget);
      // Fallback image should give count '1 / 1'
      expect(find.text('1 / 1'), findsOneWidget);
    });

    testWidgets('404 error shows localized message and retry', (tester) async {
      await pumpScreen(tester, failWithNotFound: true);
      await tester.pumpAndSettle();

      expect(find.text('Place not found.'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('Arabic RTL layout renders Arabic copy correctly', (
      tester,
    ) async {
      await pumpScreen(tester, locale: const Locale('ar'));
      await tester.pumpAndSettle();

      expect(find.text('موقع تاريخي'), findsOneWidget);
      expect(find.text('معبد فيلة'), findsOneWidget);
      // The photo counter stays "1 / N" in Arabic, not "N / 1".
      final counter = tester.widget<Text>(find.textContaining(' / ').first);
      expect(counter.textDirection, TextDirection.ltr);
      expect(counter.data, startsWith('1 / '));
      expect(find.text('جزيرة أجيليكيا، أسوان'), findsOneWidget);
      expect(find.text('الوصول بالقارب'), findsOneWidget);
      expect(find.text('تحقق قبل الزيارة'), findsOneWidget);
      expect(find.text('عن هذا المكان'), findsOneWidget);
      expect(find.text('معلومات الزيارة'), findsOneWidget);
      expect(
        find.text('ساعات العمل والأسعار غير المؤكدة محجوبة عمدًا.'),
        findsOneWidget,
      );

      final scrollable = find.descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        find.byType(PlaceReportTile),
        200,
        scrollable: scrollable,
      );
      expect(find.text('هل ترى معلومات غير دقيقة؟ أبلغ عنها.'), findsOneWidget);
    });
  });
}
