import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/eyebrow.dart';

/// "ACCOUNT" + a rounded card of rows with lines between them.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final border = context.palette.border;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: AppSpacing.xxs,
            bottom: AppSpacing.xs,
          ),
          child: Eyebrow(title, color: context.palette.link),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadii.lgAll,
            border: Border.all(color: border),
          ),
          child: ClipRRect(
            borderRadius: AppRadii.lgAll,
            child: Column(
              children: [
                for (final (i, child) in children.indexed) ...[
                  if (i > 0) Divider(height: 1, thickness: 1, color: border),
                  child,
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// One settings row: icon, title, optional value and a chevron (or a
/// [trailing] widget such as a switch).
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    this.icon,
    this.leading,
    this.value,
    this.trailing,
    this.onTap,
  });

  final IconData? icon;
  final Widget? leading;
  final String title;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              leading ?? Icon(icon, size: 22, color: palette.link),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: context.text.bodyMedium?.copyWith(color: palette.ink),
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: AppSpacing.xs),
                Text(value!, style: context.text.bodySmall),
              ],
              const SizedBox(width: AppSpacing.xs),
              trailing ??
                  Icon(
                    LucideIcons.chevronRightDir,
                    size: 20,
                    color: palette.textSecondary,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/// العربية | English, as in the design. The selected side is a white pill.
class LanguageSegment extends StatelessWidget {
  const LanguageSegment({
    super.key,
    required this.languageCode,
    required this.onChanged,
  });

  final String languageCode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final colors = context.colors;
    Widget side(String code, String label) {
      final selected = code == languageCode;
      return Expanded(
        child: Semantics(
          selected: selected,
          button: true,
          child: GestureDetector(
            onTap: selected ? null : () => onChanged(code),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              constraints: const BoxConstraints(minHeight: 44),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? colors.surface : null,
                borderRadius: AppRadii.mdAll,
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: palette.ink.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                label,
                style: context.text.titleSmall?.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? palette.ink : palette.textSecondary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: AppRadii.mdAll,
      ),
      // Arabic first, as in the design, in both directions.
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(children: [side('ar', 'العربية'), side('en', 'English')]),
      ),
    );
  }
}
