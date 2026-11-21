import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../domain/entities/guide.dart';
import '../local_guides_strings.dart';

/// Large card for the dynamically selected featured guide (is_featured == true).
/// Matches tour_guides.jpg:
/// White container, subtle border, rounded photo, gold SAMPLE PROFILE eyebrow,
/// full name, tagline, and duration pills.
class FeaturedGuideCard extends StatelessWidget {
  const FeaturedGuideCard({super.key, required this.guide, this.onTap});

  final Guide guide;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.guidesL10n;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.xlAll,
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: AppRadii.xlAll,
            border: Border.all(color: context.palette.border),
          ),
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Guide photo with fallback placeholder
              ClipRRect(
                borderRadius: AppRadii.lgAll,
                child: SizedBox(
                  width: 120,
                  height: 160,
                  child: AppImage(guide.photo ?? '', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Guide details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.sampleProfile,
                      style: context.text.labelSmall?.copyWith(
                        color: context.palette.accentGold,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      guide.fullName,
                      style: context.text.titleLarge?.copyWith(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: context.palette.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      guide.tagline,
                      style: context.text.bodySmall?.copyWith(
                        color: context.palette.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Duration pills
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xxs,
                      children: guide.durations.map((d) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: context.palette.surfaceMuted,
                            borderRadius: AppRadii.pillAll,
                          ),
                          child: Text(
                            l10n.durationLabel(d),
                            style: context.text.labelSmall?.copyWith(
                              color: context.palette.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
