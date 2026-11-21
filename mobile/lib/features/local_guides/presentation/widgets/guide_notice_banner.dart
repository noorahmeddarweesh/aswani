import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../local_guides_strings.dart';

/// Notice banner matching guide_details.jpg:
/// Soft cyan/blue background (#EFF9FB / successTint), rounded 12dp,
/// shield-check icon in riverBlue, title, and explanatory subtitle.
class GuideNoticeBanner extends StatelessWidget {
  const GuideNoticeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.guidesL10n;

    return Container(
      decoration: BoxDecoration(
        color: context.palette.successTint,
        borderRadius: AppRadii.mdAll,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            LucideIcons.shieldCheck,
            size: 22,
            color: context.palette.link,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.noticeTitle,
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: context.palette.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.noticeSubtitle,
                  style: context.text.bodySmall?.copyWith(
                    fontSize: 11,
                    height: 1.35,
                    color: context.palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
