import 'package:material_ui/material_ui.dart';

/// The raw Aswani palette: the ONLY place in the app where colour values live.
///
/// Do not use these constants in feature code. Read colours through the theme:
/// `context.colors.primary` or `context.palette.textSecondary`.
/// `tool/check_design_tokens.sh` fails CI if `AppColors` is used outside
/// `lib/core/theme/`.
///
/// Brand palette v1.0 from the UI/UX designer ("White-led · Blue identity ·
/// Golden accents", 19 Nov 2026). Supporting neutrals were sampled from the
/// exported screens and are pending the designer's confirmation.
/// A palette change is its own pull request, approved by the UI/UX designer.
abstract final class AppColors {
  // Brand palette (official, from the designer)
  /// Primary: buttons, headings, selected icon tiles, dark brand cards.
  static const Color deepBlue = Color(0xFF173B63);

  /// Secondary: links, step labels, progress, check badges, selected borders.
  static const Color riverBlue = Color(0xFF2878A8);

  /// Background.
  static const Color pureWhite = Color(0xFFFFFFFF);

  /// Secondary background: back-button circle, icon tiles, search field.
  static const Color softGray = Color(0xFFF3F6F9);

  /// Highlights.
  static const Color skyBlue = Color(0xFF8CCDE0);

  /// Accent: feature badges, active page dot, bottom-nav indicator.
  static const Color heritageGold = Color(0xFFD6AE55);

  // Supporting neutrals (sampled from the screens, to confirm with designer)
  static const Color ink = Color(0xFF0C243C);
  static const Color goldLight = Color(0xFFF4D680);
  static const Color inputFill = Color(0xFFFBFCFE);
  static const Color selectedTint = Color(0xFFF3FAFF);
  static const Color successTint = Color(0xFFEFF9FB);
  static const Color border = Color(0xFFE2EAF0);
  static const Color divider = Color(0xFFD2DCE2);
  static const Color textSecondary = Color(0xFF647888);
  static const Color textTertiary = Color(0xFF84909C);
  // Feedback (proposed: not in the designs yet)
  static const Color error = Color(0xFFC93C3C);
  static const Color success = Color(0xFF2E8B57);

  // Dark theme (proposed until the designer provides one)
  static const Color darkBackground = Color(0xFF0B1A2B);
  static const Color darkSurface = Color(0xFF12263C);
  static const Color darkSurfaceMuted = Color(0xFF1A314B);
  static const Color darkBorder = Color(0xFF2A4562);
  static const Color darkText = Color(0xFFE8EEF4);
  static const Color darkTextSecondary = Color(0xFFA7B6C4);
  static const Color darkTextTertiary = Color(0xFF7F8FA0);
  static const Color darkPrimary = Color(0xFF5AA7D8);
  static const Color darkErrorLight = Color(0xFFF08A8A);
}
