import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/router/app_page.dart';
import '../../core/router/app_routes.dart';
import 'presentation/screens/community_screen.dart';
import 'presentation/screens/my_posts_screen.dart';
import 'presentation/screens/new_post_screen.dart';
import 'presentation/screens/post_details_screen.dart';
import 'presentation/screens/story_viewer_screen.dart';

// Owner: Person B (Culture & Community). Only this file registers
// community routes.

/// Where "Share your moment" takes the photo from.
enum MomentSource { camera, gallery }

abstract final class CommunityRoutes {
  static const String newPost = '/community/new';
  static const String myPosts = '/community/mine';
  static String post(String id) => '/community/posts/$id';

  /// New post that opens the camera or the gallery first.
  static String newMoment(MomentSource source) =>
      '$newPost?source=${source.name}';

  /// Full-screen stories of one highlight circle.
  static String highlight(String id) => '/community/highlights/$id';
}

/// Routes inside the Community tab.
final List<RouteBase> communityTabRoutes = [
  GoRoute(
    path: AppRoutes.community,
    builder: (_, _) => const CommunityScreen(),
  ),
];

/// Full-screen community routes (no tab bar: they have their own bottom
/// bar or button).
final List<RouteBase> communityRootRoutes = [
  GoRoute(
    path: CommunityRoutes.newPost,
    pageBuilder: (_, state) => appPage(
      state,
      NewPostScreen(
        source: MomentSource.values
            .where((s) => s.name == state.uri.queryParameters['source'])
            .firstOrNull,
      ),
    ),
  ),
  GoRoute(
    path: CommunityRoutes.myPosts,
    pageBuilder: (_, state) => appPage(state, const MyPostsScreen()),
  ),
  GoRoute(
    path: '/community/posts/:id',
    pageBuilder: (_, state) =>
        appPage(state, PostDetailsScreen(postId: state.pathParameters['id']!)),
  ),
  GoRoute(
    path: '/community/highlights/:id',
    // Grows out of the circle like a story, not a page sliding in.
    pageBuilder: (_, state) => CustomTransitionPage(
      key: state.pageKey,
      child: StoryViewerScreen(highlightId: state.pathParameters['id']!),
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween(begin: 0.92, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    ),
  ),
];
