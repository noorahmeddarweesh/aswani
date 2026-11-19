import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_spacing.dart';
import '../extensions/context_x.dart';

/// Round icon button on a muted circle: back, notifications, filters.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 40,
  });

  /// Back button that mirrors in Arabic.
  const CircleIconButton.back({
    super.key,
    required this.tooltip,
    required this.onPressed,
    this.size = 40,
  }) : icon = LucideIcons.chevronLeftDir;

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.minTouchTarget,
      height: AppSpacing.minTouchTarget,
      child: Center(
        child: Material(
          color: context.palette.surfaceMuted,
          shape: const CircleBorder(),
          child: IconButton(
            tooltip: tooltip,
            onPressed: onPressed,
            constraints: BoxConstraints.tight(Size.square(size)),
            padding: EdgeInsets.zero,
            iconSize: size * 0.45,
            color: context.colors.primary,
            icon: Icon(icon),
          ),
        ),
      ),
    );
  }
}
