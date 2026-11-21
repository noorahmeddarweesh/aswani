import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/router/app_page.dart';
import '../../core/router/app_routes.dart';
import '../../shared/extensions/context_x.dart';
import '../../shared/widgets/coming_soon_screen.dart';
import 'presentation/screens/guide_application_received_screen.dart';
import 'presentation/screens/guide_application_screen.dart';
import 'presentation/screens/guide_details_screen.dart';
import 'presentation/screens/guide_request_review_screen.dart';
import 'presentation/screens/guide_request_screen.dart';
import 'presentation/screens/guide_request_submitted_screen.dart';
import 'presentation/screens/guides_screen.dart';

// Owner: Person A (Places & Guides). Only this file registers guides routes.

abstract final class GuidesRoutes {
  /// The user's guide requests (opened from Profile).
  static const String requests = '/guide-requests';

  /// "Know Aswan by heart?": apply to become a guide.
  static const String apply = '/guides/apply';
  static const String applyDone = '/guides/apply/done';

  static String guide(String id) => '/guides/$id';
  static String request(String id) => '/guides/$id/request';
  static String requestReview(String id) => '/guides/$id/request/review';
  static String requestDone(String id) => '/guides/$id/request/done';
}

/// Routes inside the Local guides tab.
final List<RouteBase> guidesTabRoutes = [
  GoRoute(
    path: AppRoutes.guides,
    builder: (context, _) => GuidesScreen(
      onGuideSelected: (guide) => context.push(GuidesRoutes.guide(guide.id)),
      onApplyPressed: () => context.push(GuidesRoutes.apply),
    ),
  ),
];

/// Full-screen guides routes (no tab bar: they have their own button).
final List<RouteBase> guidesRootRoutes = [
  GoRoute(
    path: GuidesRoutes.requests,
    pageBuilder: (context, state) => appPage(
      state,
      ComingSoonScreen(
        title: context.l10n.navGuides,
        icon: LucideIcons.calendarClock,
      ),
    ),
  ),
  // Before /guides/:id, so "apply" is never read as a guide id.
  GoRoute(
    path: GuidesRoutes.apply,
    pageBuilder: (context, state) => appPage(
      state,
      GuideApplicationScreen(
        onSubmittedSuccess: (_) =>
            context.pushReplacement(GuidesRoutes.applyDone),
      ),
    ),
    routes: [
      GoRoute(
        path: 'done',
        pageBuilder: (context, state) => appPage(
          state,
          GuideApplicationReceivedScreen(
            onBackToGuidesPressed: () => context.go(AppRoutes.guides),
          ),
        ),
      ),
    ],
  ),
  GoRoute(
    path: '/guides/:id',
    pageBuilder: (context, state) {
      final id = state.pathParameters['id']!;
      return appPage(
        state,
        GuideDetailsScreen(
          guideId: id,
          onBackPressed: () => context.pop(),
          onRequestPressed: () => context.push(GuidesRoutes.request(id)),
        ),
      );
    },
    routes: [
      GoRoute(
        path: 'request',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return appPage(
            state,
            GuideRequestScreen(
              guideId: id,
              onBackPressed: () => context.pop(),
              onReviewPressed: (_) =>
                  context.push(GuidesRoutes.requestReview(id)),
            ),
          );
        },
        routes: [
          GoRoute(
            path: 'review',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return appPage(
                state,
                GuideRequestReviewScreen(
                  guideId: id,
                  onBackPressed: () => context.pop(),
                  onConfirmSuccess: (_) =>
                      context.pushReplacement(GuidesRoutes.requestDone(id)),
                ),
              );
            },
          ),
          GoRoute(
            path: 'done',
            pageBuilder: (context, state) => appPage(
              state,
              GuideRequestSubmittedScreen(
                guideId: state.pathParameters['id']!,
                onHomePressed: () => context.go(AppRoutes.home),
              ),
            ),
          ),
        ],
      ),
    ],
  ),
];
