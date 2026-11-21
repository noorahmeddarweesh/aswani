import 'package:go_router/go_router.dart';

import '../../core/router/app_page.dart';
import '../../core/router/app_routes.dart';
import 'domain/entities/place_report.dart';
import 'presentation/screens/explore_screen.dart';
import 'presentation/screens/my_place_reports_screen.dart';
import 'presentation/screens/place_details_screen.dart';
import 'presentation/screens/place_report_details_screen.dart';
import 'presentation/screens/place_report_reason_screen.dart';
import 'presentation/screens/place_report_submitted_screen.dart';

// Owner: Person A (Places & Guides). Only this file registers places routes.

abstract final class PlacesRoutes {
  /// Place details (from Explore, Home and saved places).
  static String place(String id) => '/places/$id';

  /// Report a place: step 1, the reason.
  static String report(String id) => '/places/$id/report';

  /// Step 2: details and an optional photo.
  static String reportDetails(String id) => '/places/$id/report/details';

  /// "Thank you": points pending until the report is accepted.
  static String reportDone(String id, {required int points}) =>
      '/places/$id/report/done?points=$points';

  /// The user's place reports (opened from Profile).
  static const String myReports = '/place-reports';
}

/// Routes inside the Explore tab (the tab bar stays visible).
final List<RouteBase> exploreTabRoutes = [
  GoRoute(path: AppRoutes.explore, builder: (_, _) => const ExploreScreen()),
];

/// Full-screen place routes: the photo runs to the top edge, no tab bar.
final List<RouteBase> placesRootRoutes = [
  GoRoute(
    path: PlacesRoutes.myReports,
    pageBuilder: (context, state) =>
        appPage(state, const MyPlaceReportsScreen()),
  ),
  GoRoute(
    path: '/places/:id',
    pageBuilder: (context, state) {
      final id = state.pathParameters['id']!;
      return appPage(
        state,
        PlaceDetailsScreen(
          placeId: id,
          onBackTap: () => context.pop(),
          onReportTap: () => context.push(PlacesRoutes.report(id)),
        ),
      );
    },
    routes: [
      GoRoute(
        path: 'report',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return appPage(
            state,
            PlaceReportReasonScreen(
              placeId: id,
              onBackTap: () => context.pop(),
              onContinue: (_) => context.push(PlacesRoutes.reportDetails(id)),
            ),
          );
        },
        routes: [
          GoRoute(
            path: 'details',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return appPage(
                state,
                PlaceReportDetailsScreen(
                  placeId: id,
                  onBackTap: () => context.pop(),
                  onSubmitSuccess: (result) => context.pushReplacement(
                    PlacesRoutes.reportDone(id, points: result.pointsPending),
                  ),
                ),
              );
            },
          ),
          GoRoute(
            path: 'done',
            pageBuilder: (context, state) {
              final points =
                  int.tryParse(state.uri.queryParameters['points'] ?? '') ?? 25;
              return appPage(
                state,
                PlaceReportSubmittedScreen(
                  result: PlaceReportResult(
                    id: '',
                    status: 'pending',
                    pointsPending: points,
                  ),
                  // Back to the place: the reason step is under this page.
                  onDoneTap: () {
                    context.pop();
                    if (context.canPop()) context.pop();
                  },
                ),
              );
            },
          ),
        ],
      ),
    ],
  ),
];
