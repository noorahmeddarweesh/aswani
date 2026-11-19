import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/router/app_page.dart';
import '../../shared/extensions/context_x.dart';
import '../../shared/widgets/coming_soon_screen.dart';

// Owner: Person B (Culture & Community). Only this file registers
// contribution routes.

abstract final class ContributeRoutes {
  /// "Make your place part of ASWANI" (Home > Add an activity).
  static const String start = '/contribute';
}

/// Full-screen contribution routes.
final List<RouteBase> contributeRootRoutes = [
  GoRoute(
    path: ContributeRoutes.start,
    pageBuilder: (context, state) => appPage(
      state,
      ComingSoonScreen(
        title: context.l10n.homeAddActivity,
        icon: LucideIcons.mapPinPlus,
      ),
    ),
  ),
];
