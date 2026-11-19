import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/router/app_page.dart';
import '../../shared/extensions/context_x.dart';
import '../../shared/widgets/coming_soon_screen.dart';

// Owner: Person B (Culture & Community). Only this file registers profile
// routes.

abstract final class ProfileRoutes {
  /// The signed-in user's profile (Home > avatar).
  static const String profile = '/profile';
}

/// Full-screen profile routes.
final List<RouteBase> profileRootRoutes = [
  GoRoute(
    path: ProfileRoutes.profile,
    pageBuilder: (context, state) => appPage(
      state,
      ComingSoonScreen(
        title: context.l10n.profileTitle,
        icon: LucideIcons.user,
      ),
    ),
  ),
];
