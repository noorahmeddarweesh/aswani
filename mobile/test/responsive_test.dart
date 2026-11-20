import 'dart:ui';

import 'package:aswani/app.dart';
import 'package:aswani/core/router/app_router.dart';
import 'package:aswani/core/router/app_routes.dart';
import 'package:aswani/core/session/session_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_app.dart';

/// Every main screen must lay out without overflow on a small phone, with
/// the largest common system font, on a tablet and in landscape.
/// Sprint 2 screens checked at every size (each feature adds its routes).
const sprint2Routes = [
  '/community',
  '/community/new',
  '/community/posts/p_sunset',
  '/community/mine',
  '/culture',
  '/culture/stories/s_homes',
  '/culture/stories?theme=traditions',
  '/culture/saved',
  '/contribute',
  '/contribute/details',
  '/contribute/preview',
  '/contribute/done',
  '/contribute/mine',
];

void main() {
  const configs = <(String, Size, double)>[
    ('small phone', Size(360, 640), 1),
    ('large text', Size(390, 844), 2),
    ('tablet', Size(820, 1180), 1),
    ('landscape', Size(844, 390), 1),
  ];

  for (final (name, size, textScale) in configs) {
    testWidgets('no overflow: $name', (tester) async {
      tester.view.physicalSize = size * 2;
      tester.view.devicePixelRatio = 2;
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(tester.view.reset);
      reduceMotion(tester);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final container = ProviderContainer(overrides: fastMocks());
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AswaniApp(),
        ),
      );
      await tester.pumpAndSettle();
      final router = container.read(appRouterProvider);
      final session = container.read(sessionProvider.notifier);

      Future<void> visit(String route) async {
        router.go(route);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$route on $name');
      }

      for (final route in [
        AppRoutes.welcome,
        AppRoutes.onboarding,
        AppRoutes.signIn,
        AppRoutes.signUp,
        AppRoutes.forgotPassword,
        AppRoutes.resetPassword,
      ]) {
        await visit(route);
      }

      session.signedIn(const Session(userId: 'u_1', displayName: 'Laila'));
      await tester.pumpAndSettle();
      await visit(AppRoutes.personalization);

      session.preferencesSaved();
      await tester.pumpAndSettle();
      await visit(AppRoutes.home);
      await visit(AppRoutes.explore);

      // Sprint 2 (Person B)
      for (final route in sprint2Routes) {
        await visit(route);
      }
    });
  }
}
