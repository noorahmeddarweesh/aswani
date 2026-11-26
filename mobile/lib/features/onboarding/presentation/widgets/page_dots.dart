import 'package:material_ui/material_ui.dart';

import '../../../../shared/extensions/context_x.dart';

/// Page indicator: the active page is a gold pill.
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${index + 1} / $count',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == index ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == index
                    ? context.palette.accentGold
                    : context.palette.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
        ],
      ),
    );
  }
}
