import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../domain/entities/guide.dart';
import '../local_guides_strings.dart';

/// Row item for suggested (non-featured) guides matching tour_guides.jpg:
/// Rounded thumbnail (64x64), full name, tagline, gold 'Illustrative information' label, and chevron.
class SuggestedGuideCard extends StatelessWidget {
  const SuggestedGuideCard({super.key, required this.guide, this.onTap});

  final Guide guide;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.guidesL10n;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.lgAll,
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: AppRadii.lgAll,
            border: Border.all(color: context.palette.border),
          ),
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              // Avatar
              ClipRRect(
                borderRadius: AppRadii.mdAll,
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: AppImage(guide.photo ?? '', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guide.fullName,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.palette.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      guide.tagline,
                      style: context.text.bodySmall?.copyWith(
                        color: context.palette.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.illustrativeNote,
                      style: context.text.bodySmall?.copyWith(
                        color: context.palette.accentGold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Trailing chevron
              Icon(
                isRtl ? LucideIcons.chevronLeft : LucideIcons.chevronRight,
                size: 18,
                color: context.palette.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
