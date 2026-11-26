import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../local_guides_strings.dart';

/// Dark navy promotional CTA banner matching tour_guides.jpg:
/// "Know Aswan by heart?" / "Apply to offer guide services" with user icon and arrow.
class BecomeGuideCtaCard extends StatelessWidget {
  const BecomeGuideCtaCard({super.key, this.onTap});

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
            color: context.colors.primary,
            borderRadius: AppRadii.lgAll,
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.palette.onBrandSurface.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  LucideIcons.user,
                  size: 20,
                  color: context.palette.onBrandSurface,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.ctaTitle,
                      style: context.text.titleMedium?.copyWith(
                        color: context.palette.onBrandSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.ctaSubtitle,
                      style: context.text.bodySmall?.copyWith(
                        color: context.palette.onBrandSurface.withValues(
                          alpha: 0.8,
                        ),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isRtl ? LucideIcons.arrowLeft : LucideIcons.arrowRight,
                size: 20,
                color: context.palette.onBrandSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
