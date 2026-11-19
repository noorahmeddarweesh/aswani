import 'package:aswani/core/theme/app_theme.dart';
import 'package:aswani/shared/widgets/selectable_option_card.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host({required bool selected, required VoidCallback onTap}) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: SelectableOptionCard(
          icon: Icons.explore_outlined,
          title: 'Title',
          subtitle: 'Subtitle',
          selected: selected,
          onTap: onTap,
        ),
      ),
    );
  }

  testWidgets('shows a check mark only when selected', (tester) async {
    await tester.pumpWidget(host(selected: false, onTap: () {}));
    expect(find.byIcon(LucideIcons.check), findsNothing);

    await tester.pumpWidget(host(selected: true, onTap: () {}));
    expect(find.byIcon(LucideIcons.check), findsOneWidget);
  });

  testWidgets('calls onTap when tapped', (tester) async {
    var taps = 0;
    await tester.pumpWidget(host(selected: false, onTap: () => taps++));

    await tester.tap(find.text('Title'));
    expect(taps, 1);
  });
}
