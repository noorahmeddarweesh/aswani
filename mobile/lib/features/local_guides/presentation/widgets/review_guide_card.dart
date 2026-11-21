import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../domain/entities/guide.dart';
import '../local_guides_strings.dart';

/// Card displaying the selected guide matching guide_request_details.jpg:
/// - Light tinted background #F3F6F9, 16 dp border radius.
/// - 48x48 rounded thumbnail.
/// - Blue "SELECTED GUIDE" eyebrow.
/// - Full name and "Sample profile" subtitle.
class ReviewGuideCard extends StatelessWidget {
  const ReviewGuideCard({super.key, required this.guide});

  final Guide guide;

  @override
  Widget build(BuildContext context) {
    final l10n = context.guidesL10n;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.palette.surfaceMuted,
        borderRadius: AppRadii.lgAll,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: AppImage(
              guide.photo ?? '',
              fit: BoxFit.cover,
              borderRadius: AppRadii.mdAll,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.selectedGuideEyebrow,
                  style: context.text.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: context.palette.selectedBorder,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  guide.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.palette.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.reviewSampleProfile,
                  style: context.text.bodySmall?.copyWith(
                    fontSize: 12,
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
