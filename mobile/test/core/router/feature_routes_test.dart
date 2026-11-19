import 'package:aswani/core/session/session_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('Home opens Profile (avatar) and Contribute (Add activity)', (
    tester,
  ) async {
    final container = await pumpApp(tester);
    container
        .read(sessionProvider.notifier)
        .signedIn(
          const Session(
            userId: 'u_1',
            displayName: 'Laila',
            hasPreferences: true,
          ),
        );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Profile'), findsWidgets);
    expect(find.byTooltip('Back'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
    expect(router.state.matchedLocation, '/home');
  });
}
