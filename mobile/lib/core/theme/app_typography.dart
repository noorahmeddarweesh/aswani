import 'package:material_ui/material_ui.dart';

/// Font families and the app's [TextTheme].
///
/// Sizes and weights are estimated from the designs and must be confirmed
/// from Figma. Until the font files are added to pubspec.yaml, Flutter falls
/// back to the platform font; nothing breaks.
abstract final class AppTypography {
  /// UI font for everything except the welcome hero.
  static const String uiFamily = 'DMSans';

  /// Serif display font (welcome hero only).
  static const String displayFamily = 'PlayfairDisplay';

  /// Used for Arabic glyphs, in both languages.
  static const String arabicFamily = 'IBMPlexSansArabic';

  static const List<String> fallback = [arabicFamily];

  /// [primary] colours headings, [ink] strong body text,
  /// [secondary] supporting text.
  static TextTheme textTheme({
    required Color primary,
    required Color ink,
    required Color secondary,
  }) {
    TextStyle style(
      double size,
      FontWeight weight,
      Color color, {
      double height = 1.3,
      double letterSpacing = 0,
      String family = uiFamily,
    }) {
      return TextStyle(
        fontFamily: family,
        fontFamilyFallback: fallback,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
    }

    return TextTheme(
      // Welcome hero: "Discover the soul of Aswan".
      displayLarge: style(
        36,
        FontWeight.w400,
        primary,
        height: 1.15,
        family: displayFamily,
      ),
      // Hero titles on photos: "Let the Nile lead your story".
      displayMedium: style(
        28,
        FontWeight.w400,
        primary,
        height: 1.2,
        letterSpacing: -0.6,
      ),
      // Screen titles: "Welcome back", "Explore Aswan".
      headlineLarge: style(
        28,
        FontWeight.w400,
        primary,
        height: 1.2,
        letterSpacing: -0.8,
      ),
      // Onboarding titles: "Discover the Beauty of Aswan".
      headlineMedium: style(
        24,
        FontWeight.w400,
        primary,
        height: 1.25,
        letterSpacing: -0.6,
      ),
      // Section titles: "Curated for you", "Popular places".
      headlineSmall: style(20, FontWeight.w400, primary, letterSpacing: -0.5),
      // Card and list titles.
      titleLarge: style(18, FontWeight.w500, ink),
      titleMedium: style(15, FontWeight.w600, ink),
      titleSmall: style(14, FontWeight.w600, ink),
      // Body text.
      bodyLarge: style(16, FontWeight.w400, ink, height: 1.5),
      bodyMedium: style(14, FontWeight.w400, secondary, height: 1.5),
      bodySmall: style(12, FontWeight.w400, secondary, height: 1.4),
      // Buttons.
      labelLarge: style(16, FontWeight.w600, ink),
      // Field labels.
      labelMedium: style(13, FontWeight.w600, primary),
      // Eyebrows: "STEP 1 OF 8", "MEET ASWAN".
      labelSmall: style(11, FontWeight.w700, secondary, letterSpacing: 1.4),
    );
  }
}
