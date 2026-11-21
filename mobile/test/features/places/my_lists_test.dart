import 'dart:async';

import 'package:aswani/core/errors/app_exception.dart';
import 'package:aswani/core/errors/failure.dart';
import 'package:aswani/core/result/result.dart';
import 'package:aswani/core/router/app_router.dart';
import 'package:aswani/core/session/session_controller.dart';
import 'package:aswani/features/local_guides/domain/entities/guide_enums.dart';
import 'package:aswani/features/local_guides/domain/entities/guide_request.dart';
import 'package:aswani/features/local_guides/guides_routes.dart';
import 'package:aswani/features/local_guides/local_guides_providers.dart';
import 'package:aswani/features/local_guides/data/models/page_meta_dto.dart';
import 'package:aswani/features/places/data/datasources/place_details_mock_datasource.dart';
import 'package:aswani/features/places/data/models/place_report_dto.dart';
import 'package:aswani/features/places/domain/entities/place_report.dart';
import 'package:aswani/features/places/place_details_providers.dart';
import 'package:aswani/features/places/places_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

Future<(ProviderContainer, GoRouter)> _open(
  WidgetTester tester, {
  List<Override>? mocks,
}) async {
  final container = await pumpApp(tester, mocks: mocks);
  container
      .read(sessionProvider.notifier)
      .signedIn(
        const Session(
          userId: 'u_1',
          displayName: 'Laila',
          hasPreferences: true,
        ),
      );
  await tester.pumpAndSettle();
  return (container, container.read(appRouterProvider));
}

String _inDays(int days) {
  final d = DateTime.now().add(Duration(days: days));
  return '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

/// Fails every "mine" call, to check the error view and retry.
class _FailingReports extends PlaceDetailsMockDataSource {
  _FailingReports() : super(delay: Duration.zero);

  bool fail = true;

  @override
  Future<PagedListDto<PlaceReportItemDto>> getPlaceReportsMine({
    int page = 1,
    int limit = 20,
  }) async {
    if (fail) throw const AppException(code: ErrorCodes.serverError);
    return super.getPlaceReportsMine(page: page, limit: limit);
  }
}

void main() {
  testWidgets('My place reports: empty, then the new report under review', (
    tester,
  ) async {
    final (container, router) = await _open(tester);
    unawaited(router.push(PlacesRoutes.myReports));
    await tester.pumpAndSettle();
    expect(find.text('My place reports'), findsOneWidget);
    expect(find.textContaining("You haven't reported"), findsOneWidget);

    final created = await container
        .read(placeDetailsRepositoryProvider)
        .createPlaceReport(
          const PlaceReportCreate(
            placeId: 'philae',
            reason: PlaceReportReason.temporarilyClosed,
            details: 'Closed for restoration this week',
          ),
        );
    expect(created, isA<Success<dynamic>>());

    // Pull to refresh picks it up.
    await tester.fling(
      find.byType(Scrollable).first,
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();
    expect(find.text('Under review'), findsOneWidget);
    expect(find.textContaining('Temporarily closed'), findsOneWidget);

    // Tapping the report opens the place.
    await tester.tap(find.text('Under review'));
    await tester.pumpAndSettle();
    expect(router.state.matchedLocation, '/places/philae');
  });

  testWidgets('My place reports: error with retry', (tester) async {
    final source = _FailingReports();
    final (_, router) = await _open(
      tester,
      mocks: fastMocks(placeDetails: source),
    );
    unawaited(router.push(PlacesRoutes.myReports));
    await tester.pumpAndSettle();
    expect(find.text('Try again'), findsOneWidget);

    source.fail = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Try again'), findsNothing);
    expect(find.textContaining("You haven't reported"), findsOneWidget);
  });

  testWidgets('Guide requests: empty, then the sent request waiting', (
    tester,
  ) async {
    final (container, router) = await _open(tester);
    final created = await container
        .read(localGuidesRepositoryProvider)
        .createGuideRequest(
          GuideRequestCreate(
            guideId: 'youssef-el-nuby',
            date: _inDays(5),
            duration: RequestDuration.oneDay,
            startTime: '09:00',
            groupSize: 2,
            language: GuideLanguage.en,
          ),
        );
    expect(created, isA<Success<dynamic>>());

    unawaited(router.push(GuidesRoutes.requests));
    await tester.pumpAndSettle();
    expect(find.text('Guide requests'), findsOneWidget);
    expect(find.text('Waiting for the guide'), findsOneWidget);
    expect(find.textContaining('2 people'), findsOneWidget);

    await tester.tap(find.text('Waiting for the guide'));
    await tester.pumpAndSettle();
    expect(router.state.matchedLocation, '/guides/youssef-el-nuby');
  });

  testWidgets('Guide requests: empty state sends the user to the guides', (
    tester,
  ) async {
    final (_, router) = await _open(tester);
    unawaited(router.push(GuidesRoutes.requests));
    await tester.pumpAndSettle();
    expect(find.textContaining('No guide requests yet'), findsOneWidget);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Find a guide'));
    await tester.pumpAndSettle();
    expect(router.state.matchedLocation, '/guides');
  });

  testWidgets('Profile links to My place reports', (tester) async {
    final (_, router) = await _open(tester);
    router.go('/profile');
    await tester.pumpAndSettle();
    final row = find.text('My place reports');
    await tester.scrollUntilVisible(row, 200);
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(router.state.matchedLocation, PlacesRoutes.myReports);
  });
}
