import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../domain/entities/contribution.dart';

extension ContributionCategoryUi on ContributionCategory {
  String label(AppLocalizations l10n) => switch (this) {
    ContributionCategory.restaurant => l10n.contributeCatRestaurant,
    ContributionCategory.cafe => l10n.contributeCatCafe,
    ContributionCategory.entertainment => l10n.contributeCatEntertainment,
    ContributionCategory.maintenance => l10n.contributeCatMaintenance,
    ContributionCategory.clinic => l10n.contributeCatClinic,
    ContributionCategory.other => l10n.contributeCatOther,
  };

  IconData get icon => switch (this) {
    ContributionCategory.restaurant => LucideIcons.heart,
    ContributionCategory.cafe => LucideIcons.compass,
    ContributionCategory.entertainment => LucideIcons.sparkles,
    ContributionCategory.maintenance => LucideIcons.settings,
    ContributionCategory.clinic => LucideIcons.shieldCheck,
    ContributionCategory.other => LucideIcons.ellipsis,
  };
}

extension ContributionStatusUi on ContributionStatus {
  String label(AppLocalizations l10n) => switch (this) {
    ContributionStatus.pending => l10n.contributeStatusPending,
    ContributionStatus.accepted => l10n.contributeStatusAccepted,
    ContributionStatus.rejected => l10n.contributeStatusRejected,
  };
}

/// The thin segmented bar under "Activity details" (step 2 of 3, ...).
class StepBar extends StatelessWidget {
  const StepBar({super.key, required this.current, this.total = 3});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.contributeStep(current, total),
      child: Row(
        children: [
          for (var i = 1; i <= total; i++) ...[
            Expanded(
              child: AnimatedContainer(
                duration: AppMotion.medium,
                height: 3,
                decoration: BoxDecoration(
                  color: i <= current
                      ? context.colors.primary
                      : context.palette.border,
                  borderRadius: AppRadii.pillAll,
                ),
              ),
            ),
            if (i < total) const SizedBox(width: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}

/// A form field with its label above (a star when required) and its error
/// below, as in the designs.
class FormBlock extends StatelessWidget {
  const FormBlock({
    super.key,
    required this.label,
    required this.child,
    this.required = false,
    this.error,
  });

  final String label;
  final Widget child;
  final bool required;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(required ? '$label *' : label, style: context.text.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          child,
          if (error != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              error!,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Square tile with a soft background and an icon (the screens' headers).
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    this.gold = false,
    this.size = 64,
  });

  final IconData icon;
  final bool gold;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: gold
            ? palette.accentGold.withValues(alpha: 0.15)
            : palette.selectedTint,
        borderRadius: AppRadii.xlAll,
      ),
      child: Icon(
        icon,
        size: size * 0.42,
        color: gold ? palette.accentGold : context.colors.primary,
      ),
    );
  }
}
