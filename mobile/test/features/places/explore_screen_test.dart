import 'package:aswani/core/session/session_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('Explore lists places, filters by category and search', (
    tester,
  ) async {
    final container = await pumpApp(tester);
    container
        .read(sessionProvider.notifier)
        .signedIn(
          const Session(
            userId: 'u',
            displayName: 'Laila',
            hasPreferences: true,
          ),
        );
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/explore');
    await tester.pumpAndSettle();

    expect(find.text('Explore Aswan'), findsOneWidget);
    expect(find.text('Nubian Museum'), findsOneWidget);

    await tester.tap(find.text('Nubian villages'));
    await tester.pumpAndSettle();
    expect(find.text('Nubian Village'), findsOneWidget);
    expect(find.text('Nubian Museum'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('No places match this filter yet.'), findsOneWidget);
  });
}
