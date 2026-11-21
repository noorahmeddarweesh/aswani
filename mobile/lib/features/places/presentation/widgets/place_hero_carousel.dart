import 'package:aswani/shared/extensions/context_x.dart';
import 'package:aswani/shared/widgets/app_image.dart';
import 'package:aswani/shared/widgets/bookmark_icon.dart';
import 'package:aswani/shared/widgets/motion.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../places_strings.dart';

/// Full-bleed hero image carousel matching selected_place.jpg.
///
/// Features:
/// - PageView of up to 6 images (falls back to [fallbackImage] if empty).
/// - White circular back button at start (auto-mirrored in RTL).
/// - Share and bookmark circular action buttons at end.
/// - Counter pill badge at bottom-end ('1 / N').
class PlaceHeroCarousel extends StatefulWidget {
  const PlaceHeroCarousel({
    super.key,
    required this.images,
    required this.fallbackImage,
    required this.isBookmarked,
    this.showOverlay = true,
    this.onBackTap,
    this.onShareTap,
    this.onBookmarkTap,
    this.height = 340.0,
  });

  final List<String> images;
  final String fallbackImage;
  final bool isBookmarked;
  final bool showOverlay;
  final VoidCallback? onBackTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onBookmarkTap;
  final double height;

  @override
  State<PlaceHeroCarousel> createState() => _PlaceHeroCarouselState();
}

class _PlaceHeroCarouselState extends State<PlaceHeroCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;

  List<String> get _effectiveImages {
    if (widget.images.isNotEmpty) {
      return widget.images.take(6).toList();
    }
    if (widget.fallbackImage.isNotEmpty) {
      return [widget.fallbackImage];
    }
    return const [];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildCircleButton({
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
  Widget build(BuildContext context) {
    final strings = PlacesStrings.of(context);
    final effectiveImages = _effectiveImages;
    final textDirection = Directionality.of(context);

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full-bleed PageView
          if (effectiveImages.isNotEmpty)
            PageView.builder(
              controller: _pageController,
              itemCount: effectiveImages.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return SizedBox.expand(
                  child: AppImage(effectiveImages[index], fit: BoxFit.cover),
                );
              },
            )
          else
            Container(color: context.palette.surfaceMuted),

          // 2. Page counter pill (bottom-end)
          if (effectiveImages.isNotEmpty)
            Positioned.directional(
              textDirection: textDirection,
              bottom: 40, // elevated slightly above content sheet overlap
              end: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.scrim.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentPage + 1} / ${effectiveImages.length}',
                  style: TextStyle(
                    color: context.palette.onBrandSurface,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // 3. Top navigation overlay (Safe area)
          if (widget.showOverlay)
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
                        tooltip: strings.back,
                        onPressed:
                            widget.onBackTap ??
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
                        tooltip: strings.share,
                        onPressed:
                            widget.onShareTap ??
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
                        tooltip: widget.isBookmarked
                            ? strings.bookmarkRemove
                            : strings.bookmarkAdd,
                        onPressed: () {
                          Haptics.confirm();
                          widget.onBookmarkTap?.call();
                        },
                        child: BookmarkIcon(
                          saved: widget.isBookmarked,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
