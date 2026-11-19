import 'package:material_ui/material_ui.dart';

/// The raw Aswani palette: the ONLY place in the app where colour values live.
///
/// Do not use these constants in feature code. Read colours through the theme:
/// `context.colors.primary` or `context.palette.textSecondary`.
/// `tool/check_design_tokens.sh` fails CI if `AppColors` is used outside
/// `lib/core/theme/`.
///
/// Values were sampled from the exported designs (19 Nov 2026) and must be
/// confirmed against the Figma file. A palette change is its own pull request,
/// approved by the UI/UX designer.
abstract final class AppColors {
  // Brand
  static const Color navy = Color(0xFF183B63);
  static const Color ink = Color(0xFF0C243C);
  static const Color blue = Color(0xFF2878A9);
  static const Color gold = Color(0xFFD6AE55);
  static const Color goldLight = Color(0xFFF4D680);

  // Neutrals (light)
  static const Color white = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF3F7FA);
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
