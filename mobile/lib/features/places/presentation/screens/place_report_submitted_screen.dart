import 'package:aswani/features/places/domain/entities/place_report.dart';
import 'package:aswani/shared/extensions/context_x.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../places_strings.dart';
import '../widgets/report_timeline_indicator.dart';

/// Screen 11: Report Under Review (Place Report - Step 3 / Confirmation) matching report_done.jpg.
/// Route: /places/:id/report/submitted
class PlaceReportSubmittedScreen extends StatelessWidget {
  const PlaceReportSubmittedScreen({super.key, this.result, this.onDoneTap});

  final PlaceReportResult? result;
  final VoidCallback? onDoneTap;

  @override
  Widget build(BuildContext context) {
    final strings = PlacesStrings.of(context);
    final pointsText = result != null
        ? '+${result!.pointsPending}'
        : strings.reportPointsValue;

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // The content scrolls when the screen is short (landscape,
              // large text); the button stays at the bottom.
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Status Icon Tile (72x72 squircle fill #FBF5E8)
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: context.palette.accentGold.withValues(
                              alpha: 0.14,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Icon(
                              LucideIcons.clock,
                              size: 32,
                              color: context.palette.accentGold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Eyebrow
                        Text(
                          strings.reportUnderReviewEyebrow,
                          style: context.text.labelSmall?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: context.palette.accentGold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Title
                        Text(
                          strings.reportThankYou,
                          textAlign: TextAlign.center,
                          style: context.text.headlineMedium?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            color: context.palette.ink,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Subtitle
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 310),
                          child: Text(
                            strings.reportDoneSubtitle,
                            textAlign: TextAlign.center,
                            style: context.text.bodyMedium?.copyWith(
                              fontSize: 14,
                              color: context.palette.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Points Reward Card (flexible layout to prevent overflow)
                        MediaQuery.withClampedTextScaling(
                          maxScaleFactor: 1.3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: context.palette.border,
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Filled star, like the design and the
                                // points card on Profile.
                                Icon(
                                  Icons.star_rounded,
                                  size: 28,
                                  color: context.palette.accentGold,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        pointsText,
                                        style: context.text.titleMedium
                                            ?.copyWith(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: context.palette.ink,
                                            ),
                                      ),
                                      Text(
                                        strings.reportPointsPending,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.text.bodySmall?.copyWith(
                                          fontSize: 11,
                                          color: context.palette.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.palette.accentGold
                                        .withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    strings.reportPendingReview,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: context.palette.accentGold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // 3-Step Review Progress Timeline
                        MediaQuery.withClampedTextScaling(
                          maxScaleFactor: 1.3,
                          child: const ReportTimelineIndicator(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Bottom Done Button
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed:
                      onDoneTap ?? () => Navigator.of(context).maybePop(),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    strings.reportDoneButton,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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
