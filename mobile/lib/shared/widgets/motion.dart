import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_motion.dart';

/// Entrance animation: fades the child in while it rises a few pixels.
/// Give consecutive items increasing [index] for a staggered entrance.
/// Plays once, and not at all when the system asks to reduce motion.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({super.key, required this.child, this.index = 0});

  final Widget child;

  /// Position in a staggered group: item n waits n x [AppMotion.stagger].
  final int index;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    final delay = AppMotion.stagger * widget.index.clamp(0, 10);
    final total = delay + AppMotion.medium;
    _controller = AnimationController(vsync: this, duration: total);
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        delay.inMicroseconds / total.inMicroseconds,
        1,
        curve: AppMotion.enter,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isDismissed) {
      AppMotion.reduced(context)
          ? _controller.value = 1
          : _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _progress.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _progress.value) * AppMotion.enterOffset),
          child: child,
        ),
      ),
    );
  }
}

/// Shrinks the child slightly while pressed: tactile feedback for cards.
class PressableScale extends StatefulWidget {
  const PressableScale({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _set(bool value) {
    if (widget.enabled && _pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: AppMotion.short,
        curve: AppMotion.standard,
        child: widget.child,
      ),
    );
  }
}

/// Haptic feedback, in one place so it is used consistently.
abstract final class Haptics {
  /// Choosing an option, switching a chip or a tab.
  static void selection() => HapticFeedback.selectionClick();

  /// Saving something (bookmark), confirming an action.
  static void confirm() => HapticFeedback.lightImpact();
}

/// Wraps each child of a column in a [FadeSlideIn] with increasing delays,
/// so the content appears one piece after another. Spacers stay as they are.
List<Widget> staggered(List<Widget> children, {int start = 0}) {
  var index = start;
  return [
    for (final child in children)
      child is SizedBox || child is Spacer
          ? child
          : FadeSlideIn(index: index++, child: child),
  ];
}
