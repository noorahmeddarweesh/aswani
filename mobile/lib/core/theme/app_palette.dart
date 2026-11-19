import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

/// Semantic colours that Material's [ColorScheme] has no slot for.
///
/// Feature code uses these names (what a colour is FOR), never raw values:
/// `context.palette.textSecondary`, `context.palette.selectedTint`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.ink,
    required this.textSecondary,
    required this.textTertiary,
    required this.link,
    required this.border,
    required this.divider,
    required this.surfaceMuted,
    required this.inputFill,
    required this.selectedTint,
    required this.selectedBorder,
    required this.successTint,
    required this.accentGold,
    required this.accentGoldOnDark,
    required this.brandSurface,
    required this.onBrandSurface,
    required this.success,
  });

  /// Strong body text: card titles, list titles.
  final Color ink;

  /// Subtitles, descriptions, captions.
  final Color textSecondary;

  /// Placeholders, inactive navigation items, "Skip".
  final Color textTertiary;

  /// Links, step labels, "See all".
  final Color link;

  /// Text field, card and chip borders.
  final Color border;

  /// Dividers, inactive page dots and progress segments.
  final Color divider;

  /// Back button circle, icon tiles, search field.
  final Color surfaceMuted;

  /// Text field background.
  final Color inputFill;

  /// Background of a selected option card.
  final Color selectedTint;

  /// Border and check badge of a selected option card.
  final Color selectedBorder;

  /// Icon tile on reset / confirmation screens.
  final Color successTint;

  /// Feature badges, active page dot, bottom-nav indicator.
  final Color accentGold;

  /// Eyebrow labels on photos and dark cards.
  final Color accentGoldOnDark;

  /// Dark brand cards (e.g. "Contribute to Aswan's guide").
  final Color brandSurface;

  /// Text on [brandSurface].
  final Color onBrandSurface;

  /// Confirmations (proposed).
  final Color success;

  static const AppPalette light = AppPalette(
    ink: AppColors.ink,
    textSecondary: AppColors.textSecondary,
    textTertiary: AppColors.textTertiary,
    link: AppColors.blue,
    border: AppColors.border,
    divider: AppColors.divider,
    surfaceMuted: AppColors.surfaceMuted,
    inputFill: AppColors.inputFill,
    selectedTint: AppColors.selectedTint,
    selectedBorder: AppColors.blue,
    successTint: AppColors.successTint,
    accentGold: AppColors.gold,
    accentGoldOnDark: AppColors.goldLight,
    brandSurface: AppColors.navy,
    onBrandSurface: AppColors.white,
    success: AppColors.success,
  );

  /// Proposed until the designer delivers a dark palette.
  static const AppPalette dark = AppPalette(
    ink: AppColors.darkText,
    textSecondary: AppColors.darkTextSecondary,
    textTertiary: AppColors.darkTextTertiary,
    link: AppColors.darkPrimary,
    border: AppColors.darkBorder,
    divider: AppColors.darkBorder,
    surfaceMuted: AppColors.darkSurfaceMuted,
    inputFill: AppColors.darkSurface,
    selectedTint: AppColors.darkSurfaceMuted,
    selectedBorder: AppColors.darkPrimary,
    successTint: AppColors.darkSurfaceMuted,
    accentGold: AppColors.gold,
    accentGoldOnDark: AppColors.goldLight,
    brandSurface: AppColors.navy,
    onBrandSurface: AppColors.white,
    success: AppColors.success,
  );

  @override
  AppPalette copyWith({
    Color? ink,
    Color? textSecondary,
    Color? textTertiary,
    Color? link,
    Color? border,
    Color? divider,
    Color? surfaceMuted,
    Color? inputFill,
    Color? selectedTint,
    Color? selectedBorder,
    Color? successTint,
    Color? accentGold,
    Color? accentGoldOnDark,
    Color? brandSurface,
    Color? onBrandSurface,
    Color? success,
  }) {
    return AppPalette(
      ink: ink ?? this.ink,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      link: link ?? this.link,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      inputFill: inputFill ?? this.inputFill,
      selectedTint: selectedTint ?? this.selectedTint,
      selectedBorder: selectedBorder ?? this.selectedBorder,
      successTint: successTint ?? this.successTint,
      accentGold: accentGold ?? this.accentGold,
      accentGoldOnDark: accentGoldOnDark ?? this.accentGoldOnDark,
      brandSurface: brandSurface ?? this.brandSurface,
      onBrandSurface: onBrandSurface ?? this.onBrandSurface,
      success: success ?? this.success,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      ink: mix(ink, other.ink),
      textSecondary: mix(textSecondary, other.textSecondary),
      textTertiary: mix(textTertiary, other.textTertiary),
      link: mix(link, other.link),
      border: mix(border, other.border),
      divider: mix(divider, other.divider),
      surfaceMuted: mix(surfaceMuted, other.surfaceMuted),
      inputFill: mix(inputFill, other.inputFill),
      selectedTint: mix(selectedTint, other.selectedTint),
      selectedBorder: mix(selectedBorder, other.selectedBorder),
      successTint: mix(successTint, other.successTint),
      accentGold: mix(accentGold, other.accentGold),
      accentGoldOnDark: mix(accentGoldOnDark, other.accentGoldOnDark),
      brandSurface: mix(brandSurface, other.brandSurface),
      onBrandSurface: mix(onBrandSurface, other.onBrandSurface),
      success: mix(success, other.success),
    );
  }
}
