import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/router/app_routes.dart';
import '../../shared/extensions/context_x.dart';
import '../../shared/widgets/coming_soon_screen.dart';

// Owner: Person B (Culture & Community). Only this file registers culture
// routes.

/// Routes inside the Culture tab.
final List<RouteBase> cultureTabRoutes = [
  GoRoute(
    path: AppRoutes.culture,
    builder: (context, _) => ComingSoonScreen(
      title: context.l10n.navCulture,
      icon: LucideIcons.landmark,
    ),
  ),
];
