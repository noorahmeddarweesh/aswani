import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_motion.dart';
import '../extensions/context_x.dart';

/// Bookmark that pops (scale) when it changes between saved and not saved.
class BookmarkIcon extends StatelessWidget {
  const BookmarkIcon({super.key, required this.saved, this.size = 20});

  final bool saved;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.medium,
      switchInCurve: Curves.easeOutBack,
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: Icon(
        saved ? Icons.bookmark : LucideIcons.bookmark,
        key: ValueKey(saved),
        size: size,
        color: context.colors.primary,
      ),
    );
  }
}
