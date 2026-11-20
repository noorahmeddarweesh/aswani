import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/responsive/window_size.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/circle_icon_button.dart';
import '../../../../shared/widgets/eyebrow.dart';
import '../../../../shared/widgets/motion.dart';
import '../../contributions_routes.dart';
import '../../domain/entities/contribution.dart';
import '../viewmodels/contribute_view_model.dart';
import '../widgets/contribute_widgets.dart';

/// "Make your place part of ASWANI": choose what kind of place to add.
class ContributeStartScreen extends ConsumerWidget {
  const ContributeStartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    // Keeps the form alive while the next steps are open on top.
    ref.watch(contributeProvider);
    final compactBigText =
        context.windowSize == WindowSize.compact &&
        MediaQuery.textScalerOf(context).scale(10) > 13;

    return Scaffold(
      body: SafeArea(
        child: MaxWidthBox(
          maxWidth: 640,
          child: ListView(
            padding: AppSpacing.screenPadding.copyWith(
              top: AppSpacing.md,
              bottom: AppSpacing.xxl,
            ),
            children: staggered([
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: CircleIconButton.back(
                  tooltip: l10n.back,
                  onPressed: () => context.pop(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const IconBadge(icon: LucideIcons.mapPin),
                    PositionedDirectional(
                      end: -4,
                      bottom: -4,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: context.palette.accentGold,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: context.colors.surface,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          LucideIcons.plus,
                          size: 12,
                          color: context.colors.surface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Eyebrow(l10n.contributeEyebrow),
              const SizedBox(height: AppSpacing.xs),
              Text(l10n.contributeTitle, style: context.text.headlineLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(l10n.contributeBody, style: context.text.bodyMedium),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.contributeChooseCategory,
                style: context.text.titleSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              GridView.count(
                crossAxisCount: compactBigText ? 1 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: compactBigText ? 4.6 : 2.6,
                children: [
                  for (final category in ContributionCategory.values)
                    _CategoryCard(
                      category: category,
                      onTap: () {
                        ref.read(contributeProvider.notifier).start(category);
                        context.push(ContributeRoutes.details);
                      },
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.contributeReviewedNote,
                textAlign: TextAlign.center,
                style: context.text.bodySmall,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final ContributionCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.lgAll,
        side: BorderSide(color: palette.border),
      ),
      child: InkWell(
        borderRadius: AppRadii.lgAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            children: [
              Icon(category.icon, size: 18, color: palette.link),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  category.label(context.l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium?.copyWith(color: palette.ink),
                ),
              ),
              Icon(
                LucideIcons.chevronRightDir,
                size: 16,
                color: palette.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
