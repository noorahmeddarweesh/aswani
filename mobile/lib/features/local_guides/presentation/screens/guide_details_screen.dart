import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/responsive/window_size.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/utils/share.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/circle_icon_button.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/state_views.dart';
import '../local_guides_strings.dart';
import '../viewmodels/guide_details_view_model.dart';
import '../widgets/guide_duration_tile.dart';
import '../widgets/guide_notice_banner.dart';

/// Guide Details Screen matching guide_details.jpg:
/// - Hero image header with floating back and share buttons.
/// - Rounded white sheet with:
///   * Eyebrow: "SAMPLE PROFILE • NOT VERIFIED" (when is_verified is false).
///   * Full name, city & languages with mapPin icon.
///   * Short biography.
///   * "Specialties" section with pill chips.
///   * "Available tour durations" with 3-tile duration cards.
///   * "A request, not a confirmed booking" notice banner.
/// - Fixed bottom CTA: "Request this guide".
class GuideDetailsScreen extends ConsumerStatefulWidget {
  const GuideDetailsScreen({
    super.key,
    required this.guideId,
    this.onRequestPressed,
    this.onSharePressed,
    this.onBackPressed,
  });

  final String guideId;
  final VoidCallback? onRequestPressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onBackPressed;

  @override
  ConsumerState<GuideDetailsScreen> createState() => _GuideDetailsScreenState();
}

class _GuideDetailsScreenState extends ConsumerState<GuideDetailsScreen> {
  void _handleBack() {
    if (widget.onBackPressed != null) {
      widget.onBackPressed!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.guidesL10n;
    final asyncGuide = ref.watch(guideDetailsProvider(widget.guideId));

    if (asyncGuide.hasError) {
      final error = asyncGuide.error;
      final isNotFound =
          error is Failure && error.code == ErrorCodes.guideNotFound;
      final message = isNotFound ? l10n.guideNotFound : l10n.errorLoading;

      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleIconButton.back(
                  tooltip: l10n.back,
                  onPressed: _handleBack,
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.userX,
                          size: 48,
                          color: context.palette.textSecondary,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          message,
                          style: context.text.titleMedium?.copyWith(
                            color: context.palette.ink,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        if (!isNotFound)
                          PrimaryButton(
                            label: l10n.retry,
                            onPressed: () => ref.refresh(
                              guideDetailsProvider(widget.guideId),
                            ),
                          )
                        else
                          PrimaryButton(
                            label: l10n.back,
                            onPressed: _handleBack,
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

    if (asyncGuide.isLoading) {
      return _LoadingDetailsView(onBack: _handleBack);
    }

    final guide = asyncGuide.value;
    if (guide == null) {
      return _LoadingDetailsView(onBack: _handleBack);
    }

    return Scaffold(
      body: MaxWidthBox(
        child: Stack(
          children: [
            // Scrollable content
            ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                // Hero Image
                SizedBox(
                  height: 320,
                  width: double.infinity,
                  child: AppImage(guide.photo ?? '', fit: BoxFit.cover),
                ),

                // Content Sheet (overlapping slightly with rounded top)
                Transform.translate(
                  offset: const Offset(0, -24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screen,
                      AppSpacing.xl,
                      AppSpacing.screen,
                      AppSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Eyebrow (SAMPLE PROFILE • NOT VERIFIED when not verified)
                        if (!guide.isVerified) ...[
                          Text(
                            l10n.sampleProfileNotVerified,
                            style: context.text.labelSmall?.copyWith(
                              color: context.palette.accentGold,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                        ],

                        // Guide Name
                        Text(
                          guide.fullName,
                          style: context.text.headlineLarge?.copyWith(
                            fontSize: 28,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                            color: context.palette.ink,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),

                        // Location and Languages line
                        Row(
                          children: [
                            Icon(
                              LucideIcons.mapPin,
                              size: 15,
                              color: context.palette.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            Expanded(
                              child: Text(
                                '${guide.city} • ${l10n.languagesFormatted(guide.languages)}',
                                style: context.text.bodyMedium?.copyWith(
                                  color: context.palette.textSecondary,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Bio
                        Text(
                          guide.bio,
                          style: context.text.bodyMedium?.copyWith(
                            color: context.palette.textSecondary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Specialties Section
                        Text(
                          l10n.specialtiesHeader,
                          style: context.text.titleMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.palette.ink,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: guide.specialties.map((s) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: context.palette.surfaceMuted,
                                borderRadius: AppRadii.pillAll,
                              ),
                              child: Text(
                                l10n.detailsSpecialtyLabel(s),
                                style: context.text.labelMedium?.copyWith(
                                  color: context.palette.ink,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Available Tour Durations Section
                        Text(
                          l10n.availableDurationsHeader,
                          style: context.text.titleMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.palette.ink,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        GuideDurationTilesRow(durations: guide.durations),
                        const SizedBox(height: AppSpacing.xl),

                        // Notice Banner
                        const GuideNoticeBanner(),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Floating Action Bar on top of Hero Image
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleIconButton.back(
                        tooltip: l10n.back,
                        onPressed: _handleBack,
                      ),
                      CircleIconButton(
                        icon: LucideIcons.share2,
                        tooltip: l10n.share,
                        onPressed:
                            widget.onSharePressed ??
                            () => shareText(l10n.shareText(guide.fullName)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Pinned Bottom CTA Button
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.xs,
            AppSpacing.screen,
            AppSpacing.md,
          ),
          child: PrimaryButton(
            label: l10n.requestThisGuide,
            onPressed: widget.onRequestPressed,
          ),
        ),
      ),
    );
  }
}

class _LoadingDetailsView extends StatelessWidget {
  const _LoadingDetailsView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const SingleChildScrollView(
            child: Column(
              children: [
                SkeletonBox(width: double.infinity, height: 300),
                Padding(
                  padding: EdgeInsets.all(AppSpacing.screen),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 160, height: 16),
                      SizedBox(height: AppSpacing.sm),
                      SkeletonBox(width: 220, height: 28),
                      SizedBox(height: AppSpacing.sm),
                      SkeletonBox(width: 140, height: 16),
                      SizedBox(height: AppSpacing.lg),
                      SkeletonBox(width: double.infinity, height: 60),
                      SizedBox(height: AppSpacing.xl),
                      SkeletonBox(width: double.infinity, height: 80),
                      SizedBox(height: AppSpacing.md),
                      SkeletonBox(width: double.infinity, height: 70),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: CircleIconButton.back(
                  tooltip: 'Back',
                  onPressed: onBack,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
