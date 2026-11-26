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
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/motion.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../../shared/widgets/status_pill.dart';
import '../../domain/entities/place_report.dart';
import '../../places_routes.dart';
import '../places_strings.dart';
import '../viewmodels/my_place_reports_view_model.dart';

/// "My place reports" (from Profile): every place the user reported and
/// where its review stands.
class MyPlaceReportsScreen extends ConsumerWidget {
  const MyPlaceReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = PlacesStrings.of(context);
    final reports = ref.watch(myPlaceReportsProvider);
    return Scaffold(
      appBar: AppTopBar(title: strings.myReports),
      body: MaxWidthBox(
        maxWidth: 640,
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(myPlaceReportsProvider.future),
          child: reports.when(
            loading: () => ListView(
              padding: AppSpacing.screenPadding,
              children: const [
                SkeletonBox(height: 84),
                SizedBox(height: AppSpacing.sm),
                SkeletonBox(height: 84),
              ],
            ),
            error: (error, _) => ListView(
              children: [
                ErrorState(
                  message: context.l10n.errorFor(
                    error is Failure ? error.code : ErrorCodes.unknown,
                  ),
                  onRetry: () => ref.invalidate(myPlaceReportsProvider),
                ),
              ],
            ),
            data: (items) => items.isEmpty
                ? ListView(
                    children: [
                      EmptyState(
                        message: strings.myReportsEmpty,
                        icon: LucideIcons.flag,
                      ),
                    ],
                  )
                : ListView(
                    padding: AppSpacing.screenPadding,
                    children: staggered([
                      for (final r in items) _ReportTile(item: r),
                    ]),
                  ),
          ),
        ),
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.item});

  final PlaceReportItem item;

  @override
  Widget build(BuildContext context) {
    final strings = PlacesStrings.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final palette = context.palette;
    final created = DateTime.tryParse(item.createdAt);
    final tone = switch (item.status) {
      'accepted' => StatusTone.positive,
      'rejected' => StatusTone.negative,
      _ => StatusTone.pending,
    };
    final points = item.pointsAwarded ?? 0;
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
          onTap: () => context.push(PlacesRoutes.place(item.place.id)),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: AppImage(
                    item.place.image,
                    borderRadius: AppRadii.mdAll,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.place.name(lang),
                        style: context.text.titleSmall,
                      ),
                      Text(
                        [
                          strings.reasonLabel(item.reason),
                          if (created != null)
                            relativeTime(context.l10n, created),
                        ].join(' • '),
                        style: context.text.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          StatusPill(
                            label: strings.reportStatusLabel(item.status),
                            tone: tone,
                          ),
                          if (points > 0)
                            Text(
                              strings.points(points),
                              style: context.text.bodySmall?.copyWith(
                                color: palette.accentGold,
                              ),
                            ),
                        ],
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
