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

  static const double _photoWidth = 136;

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
          clipBehavior: Clip.antiAlias,
          // Photo runs edge to edge on the leading side, as tall as the card
          // (design: tour guides.jpg). The text decides the height, so the
          // card grows with large text.
          child: Stack(
            children: [
              PositionedDirectional(
                start: 0,
                top: 0,
                bottom: 0,
                width: _photoWidth,
                child: AppImage(guide.photo ?? '', fit: BoxFit.cover),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 160),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    _photoWidth + AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.sampleProfile,
                        style: context.text.labelSmall?.copyWith(
                          color: context.palette.accentGold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        guide.fullName,
                        style: context.text.headlineSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        guide.tagline,
                        style: context.text.bodySmall,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // Duration pills
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xxs,
                        children: [
                          for (final d in guide.durations)
                            Container(
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
                                style: context.text.bodySmall?.copyWith(
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
