import 'package:go_router/go_router.dart';

import '../../core/router/app_page.dart';
import 'presentation/screens/contribute_details_screen.dart';
import 'presentation/screens/contribute_done_screen.dart';
import 'presentation/screens/contribute_preview_screen.dart';
import 'presentation/screens/contribute_start_screen.dart';
import 'presentation/screens/my_contributions_screen.dart';

// Owner: Person B (Culture & Community). Only this file registers
// contribution routes.

abstract final class ContributeRoutes {
  /// "Make your place part of ASWANI" (Home > Add an activity).
  static const String start = '/contribute';
  static const String details = '/contribute/details';
  static const String preview = '/contribute/preview';
  static const String done = '/contribute/done';

  /// "Added activities" (Profile).
  static const String mine = '/contribute/mine';
}

/// Full-screen contribution routes.
final List<RouteBase> contributeRootRoutes = [
  GoRoute(
    path: ContributeRoutes.start,
    pageBuilder: (_, state) => appPage(state, const ContributeStartScreen()),
  ),
  GoRoute(
    path: ContributeRoutes.details,
    pageBuilder: (_, state) => appPage(state, const ContributeDetailsScreen()),
  ),
  GoRoute(
    path: ContributeRoutes.preview,
    pageBuilder: (_, state) => appPage(state, const ContributePreviewScreen()),
  ),
  GoRoute(
    path: ContributeRoutes.done,
    pageBuilder: (_, state) => appPage(state, const ContributeDoneScreen()),
  ),
  GoRoute(
    path: ContributeRoutes.mine,
    pageBuilder: (_, state) => appPage(state, const MyContributionsScreen()),
  ),
];
