import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/motion.dart';
import '../../domain/entities/guide_enums.dart';
import '../local_guides_strings.dart';

/// Horizontal scrolling specialty chips matching tour_guides.jpg.
/// Contract values: nubian_culture, historical_sites, nile, photography.
/// Initially selects Nubian culture; tapping an active chip clears the filter.
class SpecialtyFilterChips extends StatelessWidget {
  const SpecialtyFilterChips({
    super.key,
    required this.selectedSpecialty,
    required this.onSelected,
  });

  final GuideSpecialty? selectedSpecialty;
  final ValueChanged<GuideSpecialty> onSelected;

  static const List<GuideSpecialty> specialties = [
    GuideSpecialty.nubianCulture,
    GuideSpecialty.historicalSites,
    GuideSpecialty.nile,
    GuideSpecialty.photography,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.guidesL10n;

    return SizedBox(
      height: 44,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
        child: Row(
          children: [
            for (var i = 0; i < specialties.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.xs),
              _ChipItem(
                label: l10n.specialtyLabel(specialties[i]),
                isSelected: selectedSpecialty == specialties[i],
                onTap: () {
                  Haptics.selection();
                  onSelected(specialties[i]);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChipItem extends StatelessWidget {
  const _ChipItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? context.colors.primary
        : context.colors.surface;
    final textColor = isSelected ? Colors.white : context.palette.ink;
    final border = isSelected
        ? null
        : Border.all(color: context.palette.border);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.pillAll,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: AppRadii.pillAll,
            border: border,
          ),
          child: Text(
            label,
            style: context.text.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
