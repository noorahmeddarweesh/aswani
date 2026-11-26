import 'package:aswani/core/errors/app_exception.dart';
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
import 'package:aswani/features/local_guides/presentation/screens/guide_details_screen.dart';
import 'package:aswani/features/local_guides/presentation/widgets/guide_duration_tile.dart';
import 'package:aswani/features/local_guides/presentation/widgets/guide_notice_banner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

class _MockRepo implements LocalGuidesRepository {
  _MockRepo({this.failWithNotFound = false});

  final bool failWithNotFound;

  static const testGuide = Guide(
    id: 'youssef-el-nuby',
    fullName: 'Youssef El Nuby',
    photo: 'assets/images/places/philae_temple.jpg',
    city: 'Aswan',
    tagline: 'Nubian stories • History walks',
    languages: [GuideLanguage.ar, GuideLanguage.en],
    specialties: [
      GuideSpecialty.nubianCulture,
      GuideSpecialty.historicalSites,
      GuideSpecialty.localExperiences,
    ],
    bio: 'Passionate about local stories, Nubian architecture, and Nile experiences. Details on this profile are illustrative and do not indicate official credentials.',
    durations: [
      GuideDuration.fewHours,
      GuideDuration.oneDay,
      GuideDuration.multipleDays,
    ],
    isFeatured: true,
    isVerified: false,
  );

  @override
  Future<Result<Guide>> getGuide(String id) async {
    if (failWithNotFound) {
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
    return const Result.success(testGuide);
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
  Widget buildSubject({
    LocalGuidesRepository? repository,
    String guideId = 'youssef-el-nuby',
    VoidCallback? onRequestPressed,
    VoidCallback? onSharePressed,
    VoidCallback? onBackPressed,
    Locale locale = const Locale('en'),
    Key? key,
  }) {
    return ProviderScope(
      key: key ?? UniqueKey(),
      overrides: [
        localGuidesRepositoryProvider.overrideWithValue(
          repository ?? _MockRepo(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        home: GuideDetailsScreen(
          guideId: guideId,
          onRequestPressed: onRequestPressed,
          onSharePressed: onSharePressed,
          onBackPressed: onBackPressed,
        ),
      ),
    );
  }

  group('GuideDetailsScreen', () {
    testWidgets('renders all elements matching guide_details.jpg', (
      tester,
    ) async {
      reduceMotion(tester);
      tester.view.physicalSize = const Size(390 * 3, 1000 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // 1. Gold eyebrow (SAMPLE PROFILE • NOT VERIFIED)
      expect(find.text('SAMPLE PROFILE • NOT VERIFIED'), findsOneWidget);

      // 2. Guide Name & location line
      expect(find.text('Youssef El Nuby'), findsOneWidget);
      expect(find.text('Aswan • Arabic & English'), findsOneWidget);

      // 3. Biography text
      expect(
        find.textContaining('Passionate about local stories'),
        findsOneWidget,
      );

      // 4. Specialties section
      expect(find.text('Specialties'), findsOneWidget);
      expect(find.text('Nubian culture'), findsOneWidget);
      expect(find.text('Historical walks'), findsOneWidget);
      expect(find.text('Local experiences'), findsOneWidget);

      // 5. Available tour durations
      expect(find.text('Available tour durations'), findsOneWidget);
      expect(find.byType(GuideDurationTilesRow), findsOneWidget);
      expect(find.byType(GuideDurationTile), findsNWidgets(3));
      expect(find.text('Few hours'), findsOneWidget);
      expect(find.text('One day'), findsOneWidget);
      expect(find.text('Multiple days'), findsOneWidget);

      // 6. Notice Banner
      expect(find.byType(GuideNoticeBanner), findsOneWidget);
      expect(find.text('A request, not a confirmed booking'), findsOneWidget);
      expect(
        find.text('The guide reviews details before any time is confirmed.'),
        findsOneWidget,
      );

      // 7. Pinned Bottom CTA Button
      expect(find.text('Request this guide'), findsOneWidget);
    });

    testWidgets('tapping Request button triggers onRequestPressed callback', (
      tester,
    ) async {
      reduceMotion(tester);
      var requestTapped = false;

      await tester.pumpWidget(
        buildSubject(onRequestPressed: () => requestTapped = true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Request this guide'));
      await tester.pump();

      expect(requestTapped, isTrue);
    });

    testWidgets('tapping Back and Share buttons triggers callbacks', (
      tester,
    ) async {
      reduceMotion(tester);
      var backTapped = false;
      var shareTapped = false;

      await tester.pumpWidget(
        buildSubject(
          onBackPressed: () => backTapped = true,
          onSharePressed: () => shareTapped = true,
        ),
      );
      await tester.pumpAndSettle();

      // Tap share button
      await tester.tap(find.byTooltip('Share'));
      await tester.pump();
      expect(shareTapped, isTrue);

      // Tap back button
      await tester.tap(find.byTooltip('Back'));
      await tester.pump();
      expect(backTapped, isTrue);
    });

    testWidgets('displays 404 Guide Not Found message and back button on 404', (
      tester,
    ) async {
      reduceMotion(tester);
      var backTapped = false;

      await tester.pumpWidget(
        buildSubject(
          guideId: 'non-existent-id',
          repository: _MockRepo(failWithNotFound: true),
          onBackPressed: () => backTapped = true,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Guide not found.'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);

      await tester.tap(find.text('Back'));
      await tester.pump();
      expect(backTapped, isTrue);
    });

    testWidgets('displays Arabic copy when rendered in Arabic locale', (
      tester,
    ) async {
      reduceMotion(tester);
      tester.view.physicalSize = const Size(390 * 3, 1000 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildSubject(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      expect(find.text('ملف تجريبي • غير موثق'), findsOneWidget);
      expect(find.text('التخصصات'), findsOneWidget);
      expect(find.text('مدد الجولات المتاحة'), findsOneWidget);
      expect(find.text('طلب إرشاد، وليس حجزًا مؤكدًا'), findsOneWidget);
      expect(find.text('طلب هذا المرشد'), findsOneWidget);
    });
  });
}
