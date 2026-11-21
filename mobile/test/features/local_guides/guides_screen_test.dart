import 'package:aswani/core/result/result.dart';
import 'package:aswani/core/theme/app_theme.dart';
import 'package:aswani/features/local_guides/domain/entities/guide.dart';
import 'package:aswani/features/local_guides/domain/entities/guide_application.dart';
import 'package:aswani/features/local_guides/domain/entities/guide_enums.dart';
import 'package:aswani/features/local_guides/domain/entities/guide_request.dart';
import 'package:aswani/features/local_guides/domain/entities/page_meta.dart';
import 'package:aswani/features/local_guides/domain/repositories/local_guides_repository.dart';
import 'package:aswani/features/local_guides/local_guides_providers.dart';
import 'package:aswani/features/local_guides/presentation/screens/guides_screen.dart';
import 'package:aswani/features/local_guides/presentation/widgets/become_guide_cta_card.dart';
import 'package:aswani/features/local_guides/presentation/widgets/featured_guide_card.dart';
import 'package:aswani/features/local_guides/presentation/widgets/suggested_guide_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

class _MockRepo implements LocalGuidesRepository {
  _MockRepo({this.empty = false});

  final bool empty;

  static const testGuides = [
    Guide(
      id: 'youssef',
      fullName: 'Youssef El Nuby',
      photo: 'assets/images/places/philae_temple.jpg',
      city: 'Aswan',
      tagline: 'Nubian stories • History walks',
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
      photo: 'assets/images/home/mariam.jpg',
      city: 'Aswan',
      tagline: 'Local & family experiences',
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
    if (empty) {
      return const Result.success(
        PagedList<Guide>(
          data: [],
          meta: PageMeta(page: 1, limit: 20, total: 0, totalPages: 1),
        ),
      );
    }
    return const Result.success(
      PagedList<Guide>(
        data: testGuides,
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
  Widget buildSubject({
    LocalGuidesRepository? repository,
    ValueChanged<Guide>? onGuideSelected,
    VoidCallback? onApplyPressed,
  }) {
    return ProviderScope(
      overrides: [
        localGuidesRepositoryProvider.overrideWithValue(
          repository ?? _MockRepo(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: GuidesScreen(
          onGuideSelected: onGuideSelected,
          onApplyPressed: onApplyPressed,
        ),
      ),
    );
  }

  testWidgets('renders all screen sections matching tour_guides.jpg', (
    tester,
  ) async {
    reduceMotion(tester);
    tester.view.physicalSize = const Size(390 * 3, 1000 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // 1. Header
    expect(find.text('LOCAL KNOWLEDGE'), findsOneWidget);
    expect(find.text('Explore Aswan with a local guide'), findsOneWidget);
    expect(
      find.text(
        'Find someone who knows its stories, culture, and hidden places.',
      ),
      findsOneWidget,
    );

    // 2. Search placeholder
    expect(find.text('Search by name or specialty'), findsOneWidget);

    // 3. Specialty chips
    expect(find.text('Nubian culture'), findsOneWidget);
    expect(find.text('Historical sites'), findsOneWidget);
    expect(find.text('Nile'), findsOneWidget);
    expect(find.text('Photography'), findsOneWidget);

    // 4. Featured guide card
    expect(find.byType(FeaturedGuideCard), findsOneWidget);
    expect(find.text('SAMPLE PROFILE'), findsOneWidget);
    expect(find.text('Youssef El Nuby'), findsOneWidget);
    expect(find.text('Few hours'), findsOneWidget);
    expect(find.text('Full day'), findsOneWidget);

    // 5. Suggested guides section
    expect(find.text('Suggested guides'), findsOneWidget);
    expect(find.text('Filter →'), findsOneWidget);
    expect(find.byType(SuggestedGuideCard), findsOneWidget);
    expect(find.text('Mariam Ahmed'), findsOneWidget);
    expect(find.text('Illustrative information'), findsOneWidget);

    // 6. CTA Card
    expect(find.byType(BecomeGuideCtaCard), findsOneWidget);
    expect(find.text('Know Aswan by heart?'), findsOneWidget);
    expect(find.text('Apply to offer guide services'), findsOneWidget);
  });

  testWidgets('tapping featured or suggested guide triggers onGuideSelected', (
    tester,
  ) async {
    reduceMotion(tester);
    tester.view.physicalSize = const Size(390 * 3, 1000 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    Guide? tappedGuide;

    await tester.pumpWidget(
      buildSubject(
        onGuideSelected: (guide) => tappedGuide = guide,
      ),
    );
    await tester.pumpAndSettle();

    // Tap featured guide
    await tester.tap(find.byType(FeaturedGuideCard));
    await tester.pump();
    expect(tappedGuide?.id, 'youssef');

    // Tap suggested guide
    await tester.tap(find.byType(SuggestedGuideCard));
    await tester.pump();
    expect(tappedGuide?.id, 'mariam');
  });

  testWidgets('tapping CTA card triggers onApplyPressed', (tester) async {
    reduceMotion(tester);
    tester.view.physicalSize = const Size(390 * 3, 1000 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    var applyTapped = false;

    await tester.pumpWidget(
      buildSubject(
        onApplyPressed: () => applyTapped = true,
      ),
    );
    await tester.pumpAndSettle();

    // Scroll CTA card into view
    await tester.drag(find.byType(GuidesScreen), const Offset(0, -300));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BecomeGuideCtaCard));
    await tester.pump();
    expect(applyTapped, isTrue);
  });

  testWidgets('shows empty state when no guides found', (tester) async {
    reduceMotion(tester);
    await tester.pumpWidget(buildSubject(repository: _MockRepo(empty: true)));
    await tester.pumpAndSettle();

    expect(
      find.text('No guides available for this specialty.'),
      findsOneWidget,
    );
  });
}
