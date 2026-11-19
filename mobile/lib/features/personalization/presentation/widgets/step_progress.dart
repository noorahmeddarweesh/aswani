import 'package:material_ui/material_ui.dart';

import '../../../../shared/extensions/context_x.dart';

/// Segmented progress bar: one segment per step.
class StepProgress extends StatelessWidget {
  const StepProgress({super.key, required this.count, required this.current});

  final int count;

  /// 0-based index of the current step.
  final int current;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${current + 1} / $count',
      child: Row(
        children: [
          for (var i = 0; i < count; i++)
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: i <= current
                      ? context.palette.selectedBorder
                      : context.palette.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
