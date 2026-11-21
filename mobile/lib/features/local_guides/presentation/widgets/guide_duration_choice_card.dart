import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../domain/entities/guide_enums.dart';
import '../local_guides_strings.dart';

/// Selectable duration choice card matching requesting_a_guide.jpg:
/// - 48 dp height, 12 dp radius.
/// - Unselected: 1 dp border #E2EAF0, fill #FFFFFF.
/// - Selected: 1.5 dp border #2878A8, fill #F3FAFF or #FFFFFF, check icon.
class GuideDurationChoiceCard extends StatelessWidget {
  const GuideDurationChoiceCard({
    super.key,
    required this.duration,
    required this.isSelected,
    required this.onTap,
  });

  final RequestDuration duration;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.guidesL10n;
    final label = l10n.requestDurationLabel(duration);

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.mdAll,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? context.palette.selectedTint
              : context.colors.surface,
          borderRadius: AppRadii.mdAll,
          border: Border.all(
            color: isSelected
                ? context.palette.selectedBorder
                : context.palette.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: context.palette.ink,
                ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: AppSpacing.xxs),
              Icon(
                LucideIcons.check,
                size: 14,
                color: context.palette.selectedBorder,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
