import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_spacing.dart';

/// The full-width navy button used on every screen. Shows a spinner and
/// ignores taps while [loading], so a form cannot be sent twice.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.showArrow = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool showArrow;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final foreground = Theme.of(context).colorScheme.onPrimary;
    return FilledButton(
      onPressed: loading ? () {} : onPressed,
      child: loading
          ? SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: foreground,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
                if (showArrow) ...[
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(LucideIcons.arrowRightDir, size: 18),
                ],
              ],
            ),
    );
  }
}
