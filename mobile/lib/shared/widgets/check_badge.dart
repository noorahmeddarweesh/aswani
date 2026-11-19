import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../extensions/context_x.dart';

/// Small round check shown on a selected option.
class CheckBadge extends StatelessWidget {
  const CheckBadge({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.palette.selectedBorder,
        shape: BoxShape.circle,
      ),
      child: Icon(
        LucideIcons.check,
        size: size * 0.62,
        color: context.colors.onPrimary,
      ),
    );
  }
}
