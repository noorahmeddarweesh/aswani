import 'package:aswani/core/router/app_router.dart';
import 'package:aswani/core/session/session_controller.dart';
import 'package:aswani/features/local_guides/domain/entities/guide_enums.dart';
import 'package:aswani/features/local_guides/presentation/viewmodels/guides_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('Filter opens every specialty; picking one filters, All clears', (
    tester,
  ) async {
    final container = await pumpApp(tester);
    container
        .read(sessionProvider.notifier)
        .signedIn(
          const Session(userId: 'u_1', displayName: 'L', hasPreferences: true),
        );
    await tester.pumpAndSettle();
    container.read(appRouterProvider).go('/guides');
    await tester.pumpAndSettle();

    // Keep the provider alive while we read it.
    final sub = container.listen(guidesFilterProvider, (_, _) {});
    addTearDown(sub.close);
    expect(
      container.read(guidesFilterProvider).specialty,
      GuideSpecialty.nubianCulture,
    );

    final filter = find.text('Filter →');
    await tester.scrollUntilVisible(
      filter,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(filter);
    await tester.pumpAndSettle();
    expect(find.text('Specialties'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, 'Photography'));
    await tester.pumpAndSettle();
    expect(find.text('Specialties'), findsNothing);
    expect(
      container.read(guidesFilterProvider).specialty,
      GuideSpecialty.photography,
    );

    // The search bar's filter button opens the same sheet.
    await tester.scrollUntilVisible(
      find.byType(TextField),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Filter →'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'All'));
    await tester.pumpAndSettle();
    expect(container.read(guidesFilterProvider).specialty, isNull);
  });
}
