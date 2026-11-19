import 'package:flutter/widgets.dart';

/// Material 3 window size classes. Layouts switch on these, never on a
/// specific device.
enum WindowSize {
  /// Phones in portrait (< 600).
  compact,

  /// Large phones in landscape, small tablets (600 to 839).
  medium,

  /// Tablets (840 and above).
  expanded;

  static const double mediumMin = 600;
  static const double expandedMin = 840;

  static WindowSize fromWidth(double width) {
    if (width >= expandedMin) return WindowSize.expanded;
    if (width >= mediumMin) return WindowSize.medium;
    return WindowSize.compact;
  }

  static WindowSize of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);
}

/// Builds a different layout per [WindowSize]. [medium] and [expanded] fall
/// back to the next smaller layout when not given.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  final WidgetBuilder compact;
  final WidgetBuilder? medium;
  final WidgetBuilder? expanded;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return switch (WindowSize.fromWidth(constraints.maxWidth)) {
          WindowSize.expanded => (expanded ?? medium ?? compact)(context),
          WindowSize.medium => (medium ?? compact)(context),
          WindowSize.compact => compact(context),
        };
      },
    );
  }
}

/// Centers content and stops it growing past [maxWidth] on tablets.
class MaxWidthBox extends StatelessWidget {
  const MaxWidthBox({super.key, required this.child, this.maxWidth = 840});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
