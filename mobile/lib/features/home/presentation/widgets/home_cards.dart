import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/assets/app_images.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/eyebrow.dart';
import '../../../places/domain/entities/place.dart';

/// "Near you" card with the search field inside it.
class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({super.key, required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onPhoto = context.colors.onPrimary;
    return ClipRRect(
      borderRadius: AppRadii.xlAll,
      child: Stack(
        children: [
          const Positioned.fill(child: AppImage(AppImages.homeHero)),
          const Positioned.fill(child: PhotoScrim(strength: 0.85)),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Eyebrow(
                        l10n.homeHeroEyebrow,
                        color: context.palette.accentGoldOnDark,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.homeHeroTitle,
                        style: context.text.displayMedium?.copyWith(
                          color: onPhoto,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.homeHeroBody,
                        style: context.text.bodyMedium?.copyWith(
                          color: onPhoto.withValues(alpha: 0.88),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Material(
                  color: context.colors.surface.withValues(alpha: 0.94),
                  borderRadius: AppRadii.lgAll,
                  child: InkWell(
                    borderRadius: AppRadii.lgAll,
                    onTap: onSearch,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.search,
                            size: 20,
                            color: context.palette.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              l10n.homeSearchHint,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.bodyLarge?.copyWith(
                                color: context.palette.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

/// Square category button with a label under it.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 76),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.lgAll,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: highlighted
                    ? context.colors.primary
                    : context.palette.surfaceMuted,
                borderRadius: AppRadii.lgAll,
              ),
              child: Icon(
                icon,
                size: 22,
                color: highlighted
                    ? context.colors.onPrimary
                    : context.palette.link,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: context.text.bodySmall?.copyWith(
                color: context.palette.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Curated place card: photo with a save button, name and tagline.
class CuratedPlaceCard extends StatelessWidget {
  const CuratedPlaceCard({
    super.key,
    required this.place,
    required this.onBookmark,
  });

  final Place place;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final l10n = context.l10n;
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.55,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppImage(place.imagePath, borderRadius: AppRadii.lgAll),
                PositionedDirectional(
                  top: AppSpacing.xs,
                  end: AppSpacing.xs,
                  child: Material(
                    color: context.colors.surface,
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: place.isBookmarked
                          ? l10n.bookmarkRemove
                          : l10n.bookmarkAdd,
                      iconSize: 18,
                      onPressed: onBookmark,
                      icon: Icon(
                        place.isBookmarked
                            ? Icons.bookmark
                            : LucideIcons.bookmark,
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            place.name(lang),
            style: context.text.titleLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                LucideIcons.mapPin,
                size: 13,
                color: context.palette.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  place.tagline(lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Nubian heritage" story teaser.
class StoryCard extends StatelessWidget {
  const StoryCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onPhoto = context.colors.onPrimary;
    return AspectRatio(
      aspectRatio: 1.65,
      child: ClipRRect(
        borderRadius: AppRadii.xlAll,
        child: Material(
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const AppImage(AppImages.homeStory),
                const PhotoScrim(strength: 0.8),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Eyebrow(
                        l10n.homeStoryEyebrow,
                        color: context.palette.accentGoldOnDark,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.homeStoryTitle,
                        style: context.text.headlineMedium?.copyWith(
                          color: onPhoto,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Text(
                            l10n.homeStoryAction,
                            style: context.text.bodyMedium?.copyWith(
                              color: onPhoto,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            LucideIcons.arrowRightDir,
                            size: 16,
                            color: onPhoto,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Local guide preview card.
class GuideCard extends StatelessWidget {
  const GuideCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.xlAll,
        side: BorderSide(color: context.palette.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              const SizedBox(
                width: 86,
                height: 110,
                child: AppImage(
                  AppImages.homeGuide,
                  borderRadius: AppRadii.mdAll,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow(
                      l10n.homeGuideEyebrow,
                      color: context.palette.accentGold,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(l10n.homeGuideName, style: context.text.titleLarge),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(l10n.homeGuideBody, style: context.text.bodySmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.homeGuideAction,
                      style: context.text.titleSmall?.copyWith(
                        color: context.palette.link,
                      ),
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

/// Navy "Contribute to Aswan's guide" card with two actions.
class ContributeCard extends StatelessWidget {
  const ContributeCard({
    super.key,
    required this.onAddActivity,
    required this.onReportPlace,
  });

  final VoidCallback onAddActivity;
  final VoidCallback onReportPlace;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final onBrand = palette.onBrandSurface;

    Widget action(IconData icon, String label, VoidCallback onTap) {
      return Expanded(
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: onBrand,
            backgroundColor: onBrand.withValues(alpha: 0.08),
            side: BorderSide(color: onBrand.withValues(alpha: 0.25)),
            minimumSize: const Size(0, 46),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            textStyle: context.text.bodyMedium,
          ),
          onPressed: onTap,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16),
                const SizedBox(width: 6),
                Text(label),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.brandSurface,
        borderRadius: AppRadii.xlAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(l10n.homeContributeEyebrow, color: palette.highlight),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.homeContributeTitle,
            style: context.text.headlineMedium?.copyWith(color: onBrand),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.homeContributeBody,
            style: context.text.bodyMedium?.copyWith(
              color: onBrand.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              action(LucideIcons.plus, l10n.homeAddActivity, onAddActivity),
              const SizedBox(width: AppSpacing.xs),
              action(LucideIcons.fileText, l10n.homeReportPlace, onReportPlace),
            ],
          ),
        ],
      ),
    );
  }
}
