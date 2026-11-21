import 'package:aswani/core/errors/failure.dart';
import 'package:aswani/shared/extensions/context_x.dart';
import 'package:aswani/shared/widgets/bookmark_icon.dart';
import 'package:aswani/shared/widgets/motion.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../places_strings.dart';
import '../viewmodels/place_details_view_model.dart';
import '../widgets/place_fact_card.dart';
import '../widgets/place_hero_carousel.dart';
import '../widgets/place_report_tile.dart';
import '../widgets/place_visiting_info_card.dart';

/// Screen 8: Place Details Screen matching selected_place.jpg.
///
/// Route: /places/:id
/// Displays full-bleed hero carousel with back/share/bookmark buttons,
/// rounded white content sheet with gold eyebrow, localized title and location,
/// side-by-side key facts cards, about section, visiting info notice, and report tile.
class PlaceDetailsScreen extends ConsumerWidget {
  const PlaceDetailsScreen({
    super.key,
    required this.placeId,
    this.onBackTap,
    this.onShareTap,
    this.onReportTap,
  });

  final String placeId;
  final VoidCallback? onBackTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onReportTap;

  Widget _buildCircleButton(
    BuildContext context, {
    required Widget child,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: context.colors.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: context.colors.scrim.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: IconButton(
          tooltip: tooltip,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 40, height: 40),
          onPressed: onPressed,
          icon: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = PlacesStrings.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final placeAsync = ref.watch(placeDetailsViewModelProvider(placeId));

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: placeAsync.when(
        loading: () => Stack(
          children: [
            const Center(child: CircularProgressIndicator()),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _buildCircleButton(
                      context,
                      tooltip: strings.back,
                      onPressed:
                          onBackTap ?? () => Navigator.of(context).maybePop(),
                      child: Icon(
                        LucideIcons.chevronLeftDir,
                        size: 20,
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        error: (error, _) {
          final isNotFound =
              error is Failure &&
              (error.code == ErrorCodes.placeNotFound ||
                  error.code == 'PLACE_NOT_FOUND');
          final message = isNotFound
              ? strings.placeNotFound
              : strings.placeGenericError;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    tooltip: strings.back,
                    onPressed:
                        onBackTap ?? () => Navigator.of(context).maybePop(),
                    icon: Icon(
                      LucideIcons.chevronLeftDir,
                      color: context.colors.primary,
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.alertCircle,
                          size: 48,
                          color: context.palette.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: context.text.titleMedium?.copyWith(
                            fontSize: 16,
                            color: context.palette.ink,
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: () {
                            ref
                                .read(
                                  placeDetailsViewModelProvider(placeId)
                                      .notifier,
                                )
                                .retry();
                          },
                          child: Text(strings.retry),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          );
        },
        data: (place) {
          return Stack(
            children: [
              // 1. Hero Carousel fixed at top (without internal overlay buttons)
              PlaceHeroCarousel(
                images: place.images,
                fallbackImage: place.imagePath,
                isBookmarked: place.isBookmarked,
                showOverlay: false,
              ),

              // 2. Scrollable content sheet overlapping hero
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Gap to reveal top portion of hero carousel
                    const SizedBox(height: 316),

                    // Rounded white content sheet
                    Container(
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.scrim.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Eyebrow (Gold)
                          Text(
                            strings.eyebrow,
                            style: context.text.labelSmall?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: context.palette.accentGold,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Place Title
                          Text(
                            place.name(lang),
                            style: context.text.headlineMedium?.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w400,
                              color: context.palette.ink,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Location Row (MapPin icon + text)
                          Row(
                            children: [
                              Icon(
                                LucideIcons.mapPin,
                                size: 14,
                                color: context.palette.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  place.location(lang),
                                  style: context.text.bodyMedium?.copyWith(
                                    fontSize: 13,
                                    color: context.palette.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Key Facts Row (side-by-side cards, safe when empty)
                          if (place.facts.isNotEmpty) ...[
                            Row(
                              children: [
                                for (
                                  int i = 0;
                                  i < place.facts.length;
                                  i++
                                ) ...[
                                  Expanded(
                                    child: PlaceFactCard(fact: place.facts[i]),
                                  ),
                                  if (i != place.facts.length - 1)
                                    const SizedBox(width: 12),
                                ],
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],

                          // "About this place" Section
                          Text(
                            strings.aboutTitle,
                            style: context.text.titleMedium?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: context.palette.ink,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            place.about(lang),
                            style: context.text.bodyMedium?.copyWith(
                              fontSize: 14,
                              height: 1.5,
                              color: context.palette.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Visiting Information Card Banner
                          const PlaceVisitingInfoCard(),
                          const SizedBox(height: 24),

                          // Report Navigation Tile
                          PlaceReportTile(onReportTap: onReportTap),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Floating top navigation overlay (pinned above scroll view for hit-testing)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        // Start: White circular back button
                        _buildCircleButton(
                          context,
                          tooltip: strings.back,
                          onPressed:
                              onBackTap ??
                              () => Navigator.of(context).maybePop(),
                          child: Icon(
                            LucideIcons.chevronLeftDir,
                            size: 20,
                            color: context.colors.primary,
                          ),
                        ),
                        const Spacer(),
                        // End: Share button
                        _buildCircleButton(
                          context,
                          tooltip: strings.share,
                          onPressed:
                              onShareTap ??
                              () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(strings.placeShareCopied),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                          child: Icon(
                            LucideIcons.share2,
                            size: 18,
                            color: context.colors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // End: Bookmark button
                        _buildCircleButton(
                          context,
                          tooltip: place.isBookmarked
                              ? strings.bookmarkRemove
                              : strings.bookmarkAdd,
                          onPressed: () {
                            Haptics.confirm();
                            ref
                                .read(
                                  placeDetailsViewModelProvider(placeId)
                                      .notifier,
                                )
                                .toggleBookmark();
                          },
                          child: BookmarkIcon(
                            saved: place.isBookmarked,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
