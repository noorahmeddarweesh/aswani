import 'package:aswani/core/theme/app_theme.dart';
import 'package:aswani/shared/widgets/app_image.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('a photo that is not bundled shows the placeholder directly', (
    tester,
  ) async {
    await tester.runAsync(AppImage.preload);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const AppImage('assets/images/not_there.jpg'),
      ),
    );
    expect(find.byType(Image), findsNothing);
  });
}
