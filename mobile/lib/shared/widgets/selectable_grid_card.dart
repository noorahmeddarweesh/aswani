import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_spacing.dart';
import '../extensions/context_x.dart';
import 'check_badge.dart';

/// Option card for two-column grids (purpose, stay, style, companions...).
///
/// [compact] = the interests layout: icon on top, one label, no tile.
class SelectableGridCard extends StatelessWidget {
  const SelectableGridCard({
    super.key,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final colors = context.colors;

    final Widget iconWidget = compact
        ? Icon(icon, size: 22, color: colors.primary)
        : Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: selected ? colors.primary : palette.surfaceMuted,
              borderRadius: AppRadii.mdAll,
            ),
            child: Icon(
              icon,
              size: 18,
              color: selected ? colors.onPrimary : colors.primary,
            ),
          );

    final content = compact
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              iconWidget,
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: context.text.bodyLarge?.copyWith(fontSize: 15),
              ),
            ],
          )
        : Row(
            children: [
              iconWidget,
              const SizedBox(width: AppSpacing.sm),
              // Leaves room for the check badge in the top-end corner.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: context.text.titleSmall?.copyWith(fontSize: 12.5),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: context.text.bodySmall?.copyWith(fontSize: 10.5),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );

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
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.sm,
                  AppSpacing.sm,
                  compact ? AppSpacing.sm : AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: content,
              ),
              if (selected)
                const PositionedDirectional(
                  top: 8,
                  end: 8,
                  child: CheckBadge(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
