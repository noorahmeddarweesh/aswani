import 'package:aswani/core/router/app_router.dart';
import 'package:aswani/core/router/app_routes.dart';
import 'package:aswani/core/session/session_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const newUser = Session(userId: 'u', displayName: 'Omar');
  const readyUser = Session(
    userId: 'u',
    displayName: 'Laila',
    hasPreferences: true,
  );

  test('signed-out users only reach welcome and auth screens', () {
    expect(redirectFor(null, AppRoutes.signIn), isNull);
    expect(redirectFor(null, AppRoutes.onboarding), isNull);
    expect(redirectFor(null, AppRoutes.home), AppRoutes.welcome);
    expect(redirectFor(null, AppRoutes.personalization), AppRoutes.welcome);
  });

  test('new users go to personalisation first', () {
    expect(redirectFor(newUser, AppRoutes.signUp), AppRoutes.personalization);
    expect(redirectFor(newUser, AppRoutes.home), AppRoutes.personalization);
    expect(redirectFor(newUser, AppRoutes.personalization), isNull);
  });

  test('users with preferences land on home and stay in the app', () {
    expect(redirectFor(readyUser, AppRoutes.signIn), AppRoutes.home);
    expect(redirectFor(readyUser, AppRoutes.personalization), AppRoutes.home);
    expect(redirectFor(readyUser, AppRoutes.explore), isNull);
  });
}
