import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../local_guides_strings.dart';

/// Screen displayed after a guide application has been submitted,
/// matching guide_application-1.jpg.
class GuideApplicationReceivedScreen extends StatelessWidget {
  const GuideApplicationReceivedScreen({super.key, this.onBackToGuidesPressed});

  final VoidCallback? onBackToGuidesPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.guidesL10n;

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Warm gold squircle tile with person icon
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBF5E8), // Warm gold tint
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          LucideIcons.user,
                          size: 32,
                          color: AppColors.heritageGold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Headline
                      Text(
                        l10n.applicationReceivedTitle,
                        style: context.text.headlineMedium?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: context.palette.ink,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Reassuring body text
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 310),
                        child: Text(
                          l10n.applicationReceivedBody,
                          style: context.text.bodyMedium?.copyWith(
                            color: context.palette.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // 3 status indicator dots (Sky blue, Gold, Sky blue)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.skyBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.heritageGold,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.skyBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Pinned bottom CTA
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screen),
              child: PrimaryButton(
                label: l10n.backToGuides,
                onPressed: () {
                  if (onBackToGuidesPressed != null) {
                    onBackToGuidesPressed!();
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
