import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/router/app_routes.dart';
import '../../shared/extensions/context_x.dart';
import '../../shared/widgets/coming_soon_screen.dart';

// Owner: Person B (Culture & Community). Only this file registers
// community routes.

/// Routes inside the Community tab.
final List<RouteBase> communityTabRoutes = [
  GoRoute(
    path: AppRoutes.community,
    builder: (context, _) => ComingSoonScreen(
      title: context.l10n.navCommunity,
      icon: LucideIcons.users,
    ),
  ),
];

/// Full-screen community routes.
final List<RouteBase> communityRootRoutes = [];
