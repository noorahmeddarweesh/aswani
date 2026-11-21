import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../domain/entities/guide_enums.dart';
import '../local_guides_strings.dart';

/// "Filter": every specialty in one list (the chip row scrolls and hides
/// some). The API filters guides by specialty and search text only.
/// Returns the picked specialty, `null` for "All", or nothing when closed.
Future<void> showSpecialtyFilterSheet(
  BuildContext context, {
  required GuideSpecialty? selected,
  required ValueChanged<GuideSpecialty?> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    // Above the tab bar.
    useRootNavigator: true,
    showDragHandle: true,
    builder: (sheet) {
      final l10n = sheet.guidesL10n;
      Widget option(String label, GuideSpecialty? value) {
        final isSelected = value == selected;
        return ListTile(
          title: Text(label, style: sheet.text.bodyLarge),
          trailing: isSelected
              ? Icon(LucideIcons.check, color: sheet.colors.primary)
              : null,
          selected: isSelected,
          onTap: () {
            Navigator.of(sheet).pop();
            onSelected(value);
          },
        );
      }

      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  l10n.guidesSpecialties,
                  style: sheet.text.headlineSmall,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              option(l10n.filterAll, null),
              for (final s in GuideSpecialty.values)
                option(l10n.specialtyLabel(s), s),
            ],
          ),
        ),
      );
    },
  );
}
