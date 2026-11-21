import 'package:go_router/go_router.dart';

import '../../core/router/app_page.dart';
import '../../core/router/app_routes.dart';
import 'domain/entities/story.dart';
import 'presentation/screens/culture_screen.dart';
import 'presentation/screens/saved_reads_screen.dart';
import 'presentation/screens/stories_list_screen.dart';
import 'presentation/screens/story_screen.dart';

// Owner: Person B (Culture & Community). Only this file registers culture
// routes.

abstract final class CultureRoutes {
  static const String saved = '/culture/saved';
  static String story(String id) => '/culture/stories/$id';

  /// All stories, or one theme's (`?theme=nubian_heritage`).
  static String stories([CultureTheme? theme]) => theme == null
      ? '/culture/stories'
      : '/culture/stories?theme=${theme.wire}';
}

/// Routes inside the Culture tab (the tab bar stays).
final List<RouteBase> cultureTabRoutes = [
  GoRoute(
    path: AppRoutes.culture,
    builder: (_, _) => const CultureScreen(),
    routes: [
      GoRoute(
        path: 'stories',
        pageBuilder: (_, state) => appPage(
          state,
          StoriesListScreen(
            theme: CultureTheme.fromWire(state.uri.queryParameters['theme']),
          ),
        ),
        routes: [
          GoRoute(
            path: ':id',
            pageBuilder: (_, state) => appPage(
              state,
              StoryScreen(storyId: state.pathParameters['id']!),
            ),
          ),
        ],
      ),
      GoRoute(
        path: 'saved',
        pageBuilder: (_, state) => appPage(state, const SavedReadsScreen()),
      ),
    ],
  ),
];
