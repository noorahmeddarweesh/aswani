import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import 'presentation/screens/explore_screen.dart';

// Owner: Person A (Places & Guides). Only this file registers places routes.

/// Routes inside the Explore tab (the tab bar stays visible).
final List<RouteBase> exploreTabRoutes = [
  GoRoute(
    path: AppRoutes.explore,
    builder: (_, _) => const ExploreScreen(),
    routes: const [
      // Place details and Report a place go here (`/explore/places/:id`, ...).
    ],
  ),
];
