import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dev_gallery/presentation/screens/design_system_gallery_screen.dart';
import 'app_routes.dart';

/// The app's single router.
///
/// Sprint 2 adds the welcome, onboarding, auth and personalisation routes,
/// and a `redirect` guard that sends signed-out users to sign in.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.gallery,
    routes: [
      GoRoute(
        path: AppRoutes.gallery,
        builder: (context, state) => const DesignSystemGalleryScreen(),
      ),
    ],
  );
});
