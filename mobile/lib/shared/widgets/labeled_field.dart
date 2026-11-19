import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_spacing.dart';
import '../extensions/context_x.dart';

/// A label above a field, as in every form in the designs.
class LabeledField extends StatelessWidget {
  const LabeledField({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.text.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }
}
