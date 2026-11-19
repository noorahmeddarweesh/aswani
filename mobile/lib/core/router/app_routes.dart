/// Route paths. Screens navigate with these constants, never with
/// hand-written strings: `context.go(AppRoutes.home)`.
abstract final class AppRoutes {
  // Signed-out
  static const String welcome = '/welcome';
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Signed-in, before personalisation is done
  static const String personalization = '/personalization';

  // Main tabs
  static const String home = '/home';
  static const String explore = '/explore';
  static const String culture = '/culture';
  static const String community = '/community';
  static const String guides = '/guides';

  // Internal
  static const String gallery = '/design-system';

  static const Set<String> signedOutOnly = {
    welcome,
    onboarding,
    signIn,
    signUp,
    forgotPassword,
    resetPassword,
  };
}
