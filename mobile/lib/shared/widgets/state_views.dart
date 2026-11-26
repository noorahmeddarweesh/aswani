import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../extensions/context_x.dart';

/// Block standing in for content while it loads, with a soft moving shine
/// (shimmer). Static when the system asks to reduce motion.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppRadii.mdAll,
  });

  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppMotion.reduced(context) ? _controller.stop() : _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = context.palette.surfaceMuted;
    final shine = context.colors.surface;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value * 2 - 0.5;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [base, shine, base],
              stops: [
                (t - 0.3).clamp(0.0, 1.0),
                t.clamp(0.0, 1.0),
                (t + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Empty list: icon + one sentence.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.icon});

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Icon(
            icon ?? LucideIcons.compass,
            size: 32,
            color: context.palette.textTertiary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.text.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Error with a retry button.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Icon(LucideIcons.circleAlert, size: 32, color: context.colors.error),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.text.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size(160, 44)),
            onPressed: onRetry,
            child: Text(context.l10n.retry),
          ),
        ],
      ),
    );
  }
}
