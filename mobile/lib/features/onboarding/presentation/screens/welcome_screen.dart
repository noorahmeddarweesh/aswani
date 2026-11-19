import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/assets/app_images.dart';
import '../../../../core/config/app_settings.dart';
import '../../../../core/responsive/window_size.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/aswani_logo.dart';
import '../../../../shared/widgets/eyebrow.dart';

/// First screen: full-bleed photo, brand, language switch and the two entry
/// points (start exploring / sign in).
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final onPhoto = context.colors.onPrimary;

    return Scaffold(
      backgroundColor: context.palette.brandSurface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AppImage(AppImages.welcomeHero),
          const PhotoScrim(strength: 0.9),
          SafeArea(
            child: MaxWidthBox(
              maxWidth: 560,
              // Scrolls only when it does not fit (landscape, large text).
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: AppSpacing.screenPadding,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              const Flexible(child: AswaniLogo(onDark: true)),
                              const SizedBox(width: AppSpacing.sm),
                              const Spacer(),
                              _LanguageChip(
                                label: l10n.switchLanguage,
                                onTap: () =>
                                    ref.read(localeProvider.notifier).toggle(),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Eyebrow(
                            l10n.welcomeEyebrow,
                            color: context.palette.accentGoldOnDark,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.welcomeTitle,
                            style: context.text.displayLarge?.copyWith(
                              color: onPhoto,
                              fontFamily: context.isRtl
                                  ? AppTypography.arabicFamily
                                  : null,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.welcomeBody,
                            style: context.text.bodyLarge?.copyWith(
                              color: onPhoto.withValues(alpha: 0.88),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: onPhoto,
                              foregroundColor: context.colors.primary,
                            ),
                            onPressed: () => context.push(AppRoutes.onboarding),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    l10n.startExploring,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                const Icon(LucideIcons.arrowRightDir, size: 18),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Center(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: onPhoto,
                              ),
                              onPressed: () => context.push(AppRoutes.signIn),
                              child: Text(
                                '${l10n.welcomeHaveAccount} ${l10n.welcomeSignIn}',
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onPhoto = context.colors.onPrimary;
    return Material(
      color: onPhoto.withValues(alpha: 0.18),
      shape: StadiumBorder(
        side: BorderSide(color: onPhoto.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 36),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.globe, size: 16, color: onPhoto),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: context.text.titleSmall?.copyWith(
                    color: onPhoto,
                    fontSize: 13,
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
