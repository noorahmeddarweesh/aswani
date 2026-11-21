import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/circle_icon_button.dart';
import '../local_guides_strings.dart';

/// Search field matching tour_guides.jpg:
/// softGray fill, 12 dp border radius, search prefix icon, and trailing filter slider icon.
class GuidesSearchBar extends StatelessWidget {
  const GuidesSearchBar({
    super.key,
    this.controller,
    required this.onChanged,
    this.onFilterPressed,
  });

  final TextEditingController? controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.guidesL10n;

    return Container(
      decoration: BoxDecoration(
        color: context.palette.surfaceMuted,
        borderRadius: AppRadii.mdAll,
      ),
      padding: const EdgeInsetsDirectional.only(start: AppSpacing.sm, end: AppSpacing.xxs),
      child: Row(
        children: [
          Icon(
            LucideIcons.search,
            size: 20,
            color: context.palette.textSecondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                hintStyle: context.text.bodyMedium?.copyWith(
                  color: context.palette.textSecondary,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              ),
            ),
          ),
          CircleIconButton(
            icon: LucideIcons.slidersHorizontal,
            tooltip: l10n.filterAction,
            size: 40,
            onPressed: onFilterPressed,
          ),
        ],
      ),
    );
  }
}
