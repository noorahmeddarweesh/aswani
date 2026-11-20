import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/responsive/window_size.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/utils/relative_time.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/motion.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../contributions_routes.dart';
import '../../domain/entities/contribution.dart';
import '../viewmodels/contribute_view_model.dart';
import '../widgets/contribute_widgets.dart';

/// "Added activities" (from Profile): what the user contributed and its
/// review status.
class MyContributionsScreen extends ConsumerWidget {
  const MyContributionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final mine = ref.watch(myContributionsProvider);
    return Scaffold(
      appBar: AppTopBar(
        title: l10n.contributeMine,
        trailing: IconButton(
          tooltip: l10n.contributeAddActivity,
          icon: Icon(LucideIcons.plus, color: context.colors.primary),
          onPressed: () => context.push(ContributeRoutes.start),
        ),
      ),
      body: MaxWidthBox(
        maxWidth: 640,
        child: mine.when(
          loading: () => const Padding(
            padding: AppSpacing.screenPadding,
            child: SkeletonBox(height: 72),
          ),
          error: (error, _) => ErrorState(
            message: l10n.errorFor(
              error is Failure ? error.code : ErrorCodes.unknown,
            ),
            onRetry: () => ref.invalidate(myContributionsProvider),
          ),
          data: (page) => page.items.isEmpty
              ? EmptyState(
                  message: l10n.contributeMineEmpty,
                  icon: LucideIcons.mapPinPlus,
                )
              : ListView(
                  padding: AppSpacing.screenPadding,
                  children: staggered([
                    for (final c in page.items) _ContributionTile(item: c),
                  ]),
                ),
        ),
      ),
    );
  }
}

class _ContributionTile extends StatelessWidget {
  const _ContributionTile({required this.item});

  final Contribution item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final accepted = item.status == ContributionStatus.accepted;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.lgAll,
          side: BorderSide(color: palette.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              IconBadge(icon: item.category.icon, size: 44),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: context.text.titleSmall),
                    Text(
                      '${item.category.label(l10n)} • '
                      '${relativeTime(l10n, item.createdAt)}',
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: accepted
                          ? palette.successTint
                          : palette.accentGold.withValues(alpha: 0.15),
                      borderRadius: AppRadii.pillAll,
                    ),
                    child: Text(
                      item.status.label(l10n),
                      style: context.text.labelSmall?.copyWith(
                        color: accepted ? palette.success : palette.ink,
                      ),
                    ),
                  ),
                  if (item.pointsAwarded > 0)
                    Text(
                      l10n.contributePoints(item.pointsAwarded),
                      style: context.text.bodySmall?.copyWith(
                        color: palette.accentGold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
