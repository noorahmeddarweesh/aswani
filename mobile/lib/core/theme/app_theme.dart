import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'app_palette.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Builds the light and dark [ThemeData] from the palette.
///
/// Component styles (buttons, fields, cards...) are defined here once, so
/// every screen looks the same without styling widgets by hand.
abstract final class AppTheme {
  static final ThemeData light = _build(
    brightness: Brightness.light,
    scheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.deepBlue,
      onPrimary: AppColors.pureWhite,
      secondary: AppColors.riverBlue,
      onSecondary: AppColors.pureWhite,
      tertiary: AppColors.heritageGold,
      onTertiary: AppColors.ink,
      error: AppColors.error,
      onError: AppColors.pureWhite,
      surface: AppColors.pureWhite,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.textSecondary,
      surfaceContainerLowest: AppColors.pureWhite,
      surfaceContainerLow: AppColors.inputFill,
      surfaceContainer: AppColors.softGray,
      surfaceContainerHigh: AppColors.softGray,
      surfaceContainerHighest: AppColors.softGray,
      outline: AppColors.border,
      outlineVariant: AppColors.divider,
    ),
    palette: AppPalette.light,
    headingColor: AppColors.deepBlue,
  );

  /// Proposed until the designer delivers a dark palette.
  static final ThemeData dark = _build(
    brightness: Brightness.dark,
    scheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkBackground,
      secondary: AppColors.darkPrimary,
      onSecondary: AppColors.darkBackground,
      tertiary: AppColors.heritageGold,
      onTertiary: AppColors.darkBackground,
      error: AppColors.darkErrorLight,
      onError: AppColors.darkBackground,
      surface: AppColors.darkBackground,
      onSurface: AppColors.darkText,
      onSurfaceVariant: AppColors.darkTextSecondary,
      surfaceContainerLowest: AppColors.darkBackground,
      surfaceContainerLow: AppColors.darkSurface,
      surfaceContainer: AppColors.darkSurface,
      surfaceContainerHigh: AppColors.darkSurfaceMuted,
      surfaceContainerHighest: AppColors.darkSurfaceMuted,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkBorder,
    ),
    palette: AppPalette.dark,
    headingColor: AppColors.darkText,
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required AppPalette palette,
    required Color headingColor,
  }) {
    final textTheme = AppTypography.textTheme(
      primary: headingColor,
      ink: palette.ink,
      secondary: palette.textSecondary,
    );

    OutlineInputBorder fieldBorder(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: AppRadii.mdAll,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: AppTypography.uiFamily,
      fontFamilyFallback: AppTypography.fallback,
      textTheme: textTheme,
      extensions: [palette],
      dividerTheme: DividerThemeData(
        color: palette.divider,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: palette.divider,
          disabledForegroundColor: palette.textTertiary,
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          side: BorderSide(color: palette.border),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.link,
          minimumSize: const Size(
            AppSpacing.minTouchTarget,
            AppSpacing.minTouchTarget,
          ),
          textStyle: textTheme.titleSmall,
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: palette.inputFill,
        hintStyle: textTheme.bodyMedium?.copyWith(color: palette.textTertiary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: fieldBorder(palette.border),
        enabledBorder: fieldBorder(palette.border),
        focusedBorder: fieldBorder(palette.selectedBorder, 1.5),
        errorBorder: fieldBorder(scheme.error),
        focusedErrorBorder: fieldBorder(scheme.error, 1.5),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.xsAll),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.selectedBorder
              : null,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.brandSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: palette.onBrandSurface,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
      ),
    );
  }
}
