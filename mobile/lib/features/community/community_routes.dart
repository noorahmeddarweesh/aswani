import 'package:go_router/go_router.dart';

import '../../core/router/app_page.dart';
import '../../core/router/app_routes.dart';
import 'presentation/screens/community_screen.dart';
import 'presentation/screens/my_posts_screen.dart';
import 'presentation/screens/new_post_screen.dart';
import 'presentation/screens/post_details_screen.dart';

// Owner: Person B (Culture & Community). Only this file registers
// community routes.

abstract final class CommunityRoutes {
  static const String newPost = '/community/new';
  static const String myPosts = '/community/mine';
  static String post(String id) => '/community/posts/$id';
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
    pageBuilder: (_, state) => appPage(state, const NewPostScreen()),
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
];
