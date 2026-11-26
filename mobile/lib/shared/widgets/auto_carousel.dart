import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_motion.dart';
import '../extensions/context_x.dart';
import 'app_image.dart';

/// Auto-playing image slideshow: each image stays [interval], slowly zooming
/// (Ken Burns effect), then cross-fades into the next one.
///
/// Stops on the first image when the system asks to reduce motion, and
/// pauses automatically while its screen is hidden (tickers stop).
class AutoCarousel extends StatefulWidget {
  const AutoCarousel({
    super.key,
    required this.images,
    this.interval = AppMotion.carouselInterval,
    this.showDots = false,
    this.borderRadius,
  });

  final List<String> images;
  final Duration interval;
  final bool showDots;
  final BorderRadius? borderRadius;

  @override
  State<AutoCarousel> createState() => _AutoCarouselState();
}

class _AutoCarouselState extends State<AutoCarousel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(vsync: this, duration: widget.interval)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => _index = (_index + 1) % widget.images.length);
          _clock.forward(from: 0);
        }
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animate = !AppMotion.reduced(context) && widget.images.length > 1;
    if (animate && !_clock.isAnimating) {
      _clock.forward();
    } else if (!animate) {
      _clock.stop();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.images.elementAt(_index);
    final image = AnimatedSwitcher(
      duration: AppMotion.long,
      switchInCurve: AppMotion.standard,
      switchOutCurve: AppMotion.standard,
      layoutBuilder: (current, previous) =>
          Stack(fit: StackFit.expand, children: [...previous, ?current]),
      child: AnimatedBuilder(
        key: ValueKey(_index),
        animation: _clock,
        builder: (context, child) =>
            Transform.scale(scale: 1 + 0.06 * _clock.value, child: child),
        child: AppImage(path),
      ),
    );

    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          image,
          if (widget.showDots && widget.images.length > 1)
            PositionedDirectional(
              top: 12,
              end: 12,
              child: _Dots(count: widget.images.length, index: _index),
            ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.onPrimary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: AppMotion.medium,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: i == index ? 14 : 5,
            height: 5,
            decoration: BoxDecoration(
              color: color.withValues(alpha: i == index ? 0.95 : 0.5),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }
}
