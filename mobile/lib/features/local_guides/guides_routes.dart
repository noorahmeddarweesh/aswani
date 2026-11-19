import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/router/app_page.dart';
import '../../core/router/app_routes.dart';
import '../../shared/extensions/context_x.dart';
import '../../shared/widgets/coming_soon_screen.dart';

// Owner: Person A (Places & Guides). Only this file registers guides routes.

abstract final class GuidesRoutes {
  /// The user's guide requests (opened from Profile).
  static const String requests = '/guide-requests';
}

/// Routes inside the Local guides tab.
final List<RouteBase> guidesTabRoutes = [
  GoRoute(
    path: AppRoutes.guides,
    builder: (context, _) =>
        ComingSoonScreen(title: context.l10n.navGuides, icon: LucideIcons.map),
  ),
];

/// Full-screen guides routes.
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
];
