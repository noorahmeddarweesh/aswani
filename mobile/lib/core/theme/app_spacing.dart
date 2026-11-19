import 'package:flutter/widgets.dart';

/// Spacing scale (logical pixels). Use these instead of raw numbers.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Horizontal padding of every screen.
  static const double screen = 24;

  /// Width at which content stops growing on tablets.
  static const double maxContentWidth = 840;

  /// Minimum touch target (Material and WCAG guidance).
  static const double minTouchTarget = 48;

  /// Height of the primary full-width button.
  static const double buttonHeight = 52;

  /// Symmetric, so it is the same in LTR and RTL.
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screen,
  );
}

/// Corner radii.
abstract final class AppRadii {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;

  static const BorderRadius xsAll = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}
