import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../domain/entities/guide_enums.dart';
import '../local_guides_strings.dart';

/// Tile displaying an offered tour duration matching guide_details.jpg:
/// Soft gray background, rounded 16dp, Lucide icon in primary blue, and duration label.
class GuideDurationTile extends StatelessWidget {
  const GuideDurationTile({super.key, required this.duration});

  final GuideDuration duration;

  IconData get _icon {
    switch (duration) {
      case GuideDuration.fewHours:
        return LucideIcons.clock;
      case GuideDuration.oneDay:
        return LucideIcons.calendar;
      case GuideDuration.multipleDays:
        return LucideIcons.calendarDays;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.guidesL10n;

    return Container(
      height: 76,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.palette.surfaceMuted,
        borderRadius: AppRadii.lgAll,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_icon, size: 20, color: context.colors.primary),
          const SizedBox(height: 6),
          Text(
            l10n.detailsDurationLabel(duration),
            style: context.text.labelSmall?.copyWith(
              color: context.palette.ink,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Row of duration tiles matching the 3-tile grid in guide_details.jpg.
class GuideDurationTilesRow extends StatelessWidget {
  const GuideDurationTilesRow({super.key, required this.durations});

  final List<GuideDuration> durations;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < durations.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(child: GuideDurationTile(duration: durations[i])),
        ],
      ],
    );
  }
}
