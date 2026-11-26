import 'package:material_ui/material_ui.dart';

/// Motion tokens: every animation in the app uses these durations and curves,
/// so the whole app moves the same way.
abstract final class AppMotion {
  /// Taps, toggles, small state changes.
  static const Duration short = Duration(milliseconds: 150);

  /// Most transitions: entrances, page changes, chips.
  static const Duration medium = Duration(milliseconds: 300);

  /// Large surfaces: hero image cross-fade.
  static const Duration long = Duration(milliseconds: 900);

  /// Delay between items of a staggered entrance.
  static const Duration stagger = Duration(milliseconds: 60);

  /// How long each carousel image stays on screen.
  static const Duration carouselInterval = Duration(seconds: 4);

  /// Decelerate: things arriving on screen.
  static const Curve enter = Curves.easeOutCubic;

  /// Standard: things moving or changing in place.
  static const Curve standard = Curves.easeInOutCubic;

  /// Distance (logical px) an entering element travels upward.
  static const double enterOffset = 16;

  /// True when the user asked the system to reduce motion. Every looping or
  /// decorative animation must stop then.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;
}
