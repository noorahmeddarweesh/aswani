import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_spacing.dart';
import '../extensions/context_x.dart';

/// How a review status reads: waiting, done well, or turned down.
enum StatusTone { pending, positive, negative }

/// Small rounded label for a review status ("Under review", "Accepted").
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.tone});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (background, foreground) = switch (tone) {
      StatusTone.pending => (
        palette.accentGold.withValues(alpha: 0.15),
        palette.ink,
      ),
      StatusTone.positive => (palette.successTint, palette.success),
      StatusTone.negative => (
        context.colors.error.withValues(alpha: 0.1),
        context.colors.error,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadii.pillAll,
      ),
      child: Text(
        label,
        style: context.text.labelSmall?.copyWith(color: foreground),
      ),
    );
  }
}
