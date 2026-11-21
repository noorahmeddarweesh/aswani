import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_spacing.dart';
import '../extensions/context_x.dart';

/// The confirmation card of the designs (Log out?, Delete account?): an icon,
/// a title, one line of text, a filled button and Cancel. Returns true when
/// the user confirms.
Future<bool> showConfirmSheet(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  IconData icon = LucideIcons.circleAlert,
  bool destructive = false,
}) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ConfirmCard(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      icon: icon,
      destructive: destructive,
    ),
  );
  return confirmed ?? false;
}

class _ConfirmCard extends StatelessWidget {
  const _ConfirmCard({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.icon,
    required this.destructive,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final IconData icon;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = destructive ? colors.error : colors.primary;
    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Material(
            color: colors.surface,
            borderRadius: AppRadii.xlAll,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.1),
                        borderRadius: AppRadii.mdAll,
                      ),
                      child: Icon(icon, color: accent),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: context.text.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: context.text.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(confirmLabel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(context.l10n.cancel),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
