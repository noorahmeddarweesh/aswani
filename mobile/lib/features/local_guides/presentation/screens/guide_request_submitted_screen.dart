import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../local_guides_strings.dart';

/// Request submitted confirmation screen matching guide_request_done.jpg:
/// - Centered light-blue squircle tile with check icon.
/// - 24 sp "Request submitted" heading.
/// - Explanation body text.
/// - 3 decorative status dots (sky blue, gold, sky blue).
/// - Pinned bottom CTA: "Back to home".
class GuideRequestSubmittedScreen extends StatelessWidget {
  const GuideRequestSubmittedScreen({
    super.key,
    required this.guideId,
    this.onHomePressed,
  });

  final String guideId;
  final VoidCallback? onHomePressed;

  void _handleHome(BuildContext context) {
    if (onHomePressed != null) {
      onHomePressed!();
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.guidesL10n;

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Centered Content
            Expanded(
              // Scrolls when the screen is short (landscape, large text).
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screen,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Squircle Check Icon Tile
                        Container(
                          key: const Key('submitted_check_tile'),
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: context.palette.successTint,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            LucideIcons.check,
                            size: 32,
                            color: context.palette.selectedBorder,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Title Heading
                        Text(
                          l10n.requestSubmittedTitle,
                          key: const Key('submitted_title'),
                          textAlign: TextAlign.center,
                          style: context.text.headlineSmall?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: context.palette.ink,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Body Paragraph
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: Text(
                            l10n.requestSubmittedBody,
                            key: const Key('submitted_body'),
                            textAlign: TextAlign.center,
                            style: context.text.bodyMedium?.copyWith(
                              fontSize: 14,
                              color: context.palette.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // 3 Status Dots: Sky Blue, Gold, Sky Blue
                        Row(
                          key: const Key('submitted_status_dots'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context.palette.highlight,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context.palette.accentGold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context.palette.highlight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Pinned Bottom CTA Bar
            Container(
              padding: const EdgeInsets.all(AppSpacing.screen),
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border(top: BorderSide(color: context.palette.border)),
              ),
              child: PrimaryButton(
                key: const Key('submitted_back_to_home_button'),
                label: l10n.backToHome,
                onPressed: () => _handleHome(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
