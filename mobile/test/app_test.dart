import 'package:aswani/app.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app starts on the design-system gallery in English', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: AswaniApp()));
    await tester.pumpAndSettle();

    expect(find.text('Design system'), findsOneWidget);
  });

  testWidgets('switching language shows Arabic, right to left', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AswaniApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();

    expect(find.text('نظام التصميم'), findsOneWidget);
    final direction = Directionality.of(
      tester.element(find.text('نظام التصميم')),
    );
    expect(direction, TextDirection.rtl);
  });
}
