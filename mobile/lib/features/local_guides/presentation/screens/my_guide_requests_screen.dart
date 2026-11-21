import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/responsive/window_size.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/motion.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../../shared/widgets/status_pill.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../domain/entities/guide_enums.dart';
import '../../domain/entities/guide_request.dart';
import '../../guides_routes.dart';
import '../local_guides_strings.dart';
import '../viewmodels/my_guide_requests_view_model.dart';

/// "Guide requests" (from Profile): the tours the user asked for and
/// whether each guide has answered.
class MyGuideRequestsScreen extends ConsumerWidget {
  const MyGuideRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.guidesL10n;
    final requests = ref.watch(myGuideRequestsProvider);
    return Scaffold(
      appBar: AppTopBar(title: l10n.myRequests),
      body: MaxWidthBox(
        maxWidth: 640,
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(myGuideRequestsProvider.future),
          child: requests.when(
            loading: () => ListView(
              padding: AppSpacing.screenPadding,
              children: const [
                SkeletonBox(height: 96),
                SizedBox(height: AppSpacing.sm),
                SkeletonBox(height: 96),
              ],
            ),
            error: (error, _) => ListView(
              children: [
                ErrorState(
                  message: context.l10n.errorFor(
                    error is Failure ? error.code : ErrorCodes.unknown,
                  ),
                  onRetry: () => ref.invalidate(myGuideRequestsProvider),
                ),
              ],
            ),
            data: (items) => items.isEmpty
                ? ListView(
                    padding: AppSpacing.screenPadding,
                    children: [
                      EmptyState(
                        message: l10n.myRequestsEmpty,
                        icon: LucideIcons.calendarDays,
                      ),
                      Center(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(160, 44),
                          ),
                          onPressed: () => context.go(AppRoutes.guides),
                          child: Text(l10n.myRequestsFind),
                        ),
                      ),
                    ],
                  )
                : ListView(
                    padding: AppSpacing.screenPadding,
                    children: staggered([
                      for (final r in items) _RequestTile(item: r),
                    ]),
                  ),
          ),
        ),
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({required this.item});

  final GuideRequestItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.guidesL10n;
    final palette = context.palette;
    final tone = switch (item.status) {
      RequestStatus.pending => StatusTone.pending,
      RequestStatus.accepted => StatusTone.positive,
      RequestStatus.rejected => StatusTone.negative,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.lgAll,
          side: BorderSide(color: palette.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(GuidesRoutes.guide(item.guide.id)),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserAvatar(
                  name: item.guide.fullName,
                  imageUrl: item.guide.photo,
                  size: 48,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.guide.fullName, style: context.text.titleSmall),
                      Text(
                        '${l10n.formatReviewDate(item.date)} • '
                        '${item.startTime}',
                        style: context.text.bodySmall,
                      ),
                      Text(
                        '${l10n.reviewDurationFormatted(item.duration, item.durationHours)}'
                        ' • ${l10n.requestGroupSizeFormatted(item.groupSize)}',
                        style: context.text.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      StatusPill(
                        label: l10n.requestStatusLabel(item.status),
                        tone: tone,
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
