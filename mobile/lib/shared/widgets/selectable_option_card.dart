import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_spacing.dart';
import '../extensions/context_x.dart';

/// The option card used across personalisation (persona, purpose, stay,
/// interests...). One widget, so every step looks identical.
///
/// Selected: tinted background, blue border and a check mark.
class SelectableOptionCard extends StatelessWidget {
  const SelectableOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final colors = context.colors;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? palette.selectedTint : colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.lgAll,
          side: BorderSide(
            color: selected ? palette.selectedBorder : palette.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSpacing.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: palette.surfaceMuted,
                      borderRadius: AppRadii.mdAll,
                    ),
                    child: Icon(icon, size: 20, color: colors.primary),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: context.text.titleMedium),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          Text(subtitle!, style: context.text.bodySmall),
                        ],
                      ],
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check, color: palette.selectedBorder),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
