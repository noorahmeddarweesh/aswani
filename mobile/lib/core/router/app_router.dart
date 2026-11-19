import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/community/community_routes.dart';
import '../../features/contributions/contributions_routes.dart';
import '../../features/culture/culture_routes.dart';
import '../../features/dev_gallery/presentation/screens/design_system_gallery_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/local_guides/guides_routes.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/personalization/presentation/screens/personalization_screen.dart';
import '../../features/places/places_routes.dart';
import '../../features/profile/profile_routes.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/fade_indexed_stack.dart';
import '../session/session_controller.dart';
import 'app_page.dart';
import 'app_routes.dart';

// Each feature registers its own routes in `<feature>_routes.dart`; this file
// only puts them together, so two people never edit the same route list.
// `*TabRoutes` open inside a tab (the tab bar stays); `*RootRoutes` open full
// screen above the tabs.

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
        pageBuilder: (_, state) => appPage(state, const WelcomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (_, state) => appPage(state, const OnboardingScreen()),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        pageBuilder: (_, state) => appPage(state, const SignInScreen()),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        pageBuilder: (_, state) => appPage(state, const SignUpScreen()),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (_, state) => appPage(state, const ForgotPasswordScreen()),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        pageBuilder: (_, state) => appPage(
          state,
          ResetPasswordScreen(
            identifier: state.uri.queryParameters['identifier'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.personalization,
        pageBuilder: (_, state) =>
            appPage(state, const PersonalizationScreen()),
      ),
      StatefulShellRoute(
        builder: (_, _, shell) => AppShell(navigationShell: shell),
        navigatorContainerBuilder: (_, shell, children) =>
            FadeIndexedStack(index: shell.currentIndex, children: children),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (_, _) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(routes: exploreTabRoutes),
          StatefulShellBranch(routes: cultureTabRoutes),
          StatefulShellBranch(routes: communityTabRoutes),
          StatefulShellBranch(routes: guidesTabRoutes),
        ],
      ),
      ...communityRootRoutes,
      ...contributeRootRoutes,
      ...profileRootRoutes,
      ...guidesRootRoutes,
      GoRoute(
        path: AppRoutes.gallery,
        pageBuilder: (_, state) =>
            appPage(state, const DesignSystemGalleryScreen()),
      ),
    ],
  );
});
