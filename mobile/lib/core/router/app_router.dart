import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/dev_gallery/presentation/screens/design_system_gallery_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/personalization/presentation/screens/personalization_screen.dart';
import '../../features/places/presentation/screens/explore_screen.dart';
import '../../shared/extensions/context_x.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/coming_soon_screen.dart';
import '../session/session_controller.dart';
import 'app_routes.dart';

/// Where a user may be, given their session (pure function, unit-tested).
///
/// - Signed out: only the welcome / onboarding / auth screens.
/// - Signed in without preferences: personalisation first.
/// - Signed in with preferences: the main tabs.
String? redirectFor(Session? session, String location) {
  if (location == AppRoutes.gallery) return null;
  final signedOutPage = AppRoutes.signedOutOnly.contains(location);
  if (session == null) return signedOutPage ? null : AppRoutes.welcome;
  if (!session.hasPreferences) {
    return location == AppRoutes.personalization
        ? null
        : AppRoutes.personalization;
  }
  if (signedOutPage || location == AppRoutes.personalization) {
    return AppRoutes.home;
  }
  return null;
}

/// The app's single router. It re-checks [redirectFor] whenever the session
/// changes, so screens never navigate after sign-in themselves.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.welcome,
    refreshListenable: refresh,
    redirect: (context, state) =>
        redirectFor(ref.read(sessionProvider), state.matchedLocation),
    routes: [
      GoRoute(path: '/', redirect: (_, _) => AppRoutes.welcome),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (_, _) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(path: AppRoutes.signIn, builder: (_, _) => const SignInScreen()),
      GoRoute(path: AppRoutes.signUp, builder: (_, _) => const SignUpScreen()),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (_, state) => ResetPasswordScreen(
          identifier: state.uri.queryParameters['identifier'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.personalization,
        builder: (_, _) => const PersonalizationScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (_, _) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.explore,
                builder: (_, _) => const ExploreScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.culture,
                builder: (context, _) => ComingSoonScreen(
                  title: context.l10n.navCulture,
                  icon: LucideIcons.landmark,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.community,
                builder: (context, _) => ComingSoonScreen(
                  title: context.l10n.navCommunity,
                  icon: LucideIcons.users,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.guides,
                builder: (context, _) => ComingSoonScreen(
                  title: context.l10n.navGuides,
                  icon: LucideIcons.map,
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.gallery,
        builder: (_, _) => const DesignSystemGalleryScreen(),
      ),
    ],
  );
});
