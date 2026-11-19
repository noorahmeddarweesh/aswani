import 'package:aswani/core/theme/app_colors.dart';
import 'package:aswani/core/theme/app_palette.dart';
import 'package:aswani/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme', () {
    test('light theme uses the design palette', () {
      final theme = AppTheme.light;

      expect(theme.colorScheme.primary, AppColors.navy);
      expect(theme.colorScheme.secondary, AppColors.blue);
      expect(theme.extension<AppPalette>(), AppPalette.light);
    });

    test('both themes register the AppPalette extension', () {
      expect(AppTheme.light.extension<AppPalette>(), isNotNull);
      expect(AppTheme.dark.extension<AppPalette>(), isNotNull);
    });
  });
}
