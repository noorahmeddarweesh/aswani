import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/responsive/window_size.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/circle_icon_button.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/state_views.dart';
import '../viewmodels/home_view_model.dart';
import '../widgets/home_cards.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.comingSoonTitle)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final name = ref.watch(sessionProvider)?.displayName ?? '';
    final curated = ref.watch(homeViewModelProvider);
    final greeting = switch (dayPartOf(DateTime.now())) {
      DayPart.morning => l10n.homeGreetingMorning(name),
      DayPart.afternoon => l10n.homeGreetingAfternoon(name),
      DayPart.evening => l10n.homeGreetingEvening(name),
    };

    final categories = [
      (LucideIcons.landmark, l10n.categoryPlaces, AppRoutes.explore),
      (LucideIcons.palette, l10n.categoryCulture, AppRoutes.culture),
      (LucideIcons.heart, l10n.categoryFood, AppRoutes.explore),
      (LucideIcons.sparkles, l10n.categoryLocal, AppRoutes.explore),
      (LucideIcons.mapPin, l10n.categoryServices, AppRoutes.explore),
    ];

    return Scaffold(
      body: SafeArea(
        child: MaxWidthBox(
          child: RefreshIndicator(
            onRefresh: () => ref.refresh(homeViewModelProvider.future),
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting,
                              style: context.text.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.mapPin,
                                  size: 14,
                                  color: context.palette.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.homeLocation,
                                  style: context.text.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      CircleIconButton(
                        icon: LucideIcons.bell,
                        tooltip: l10n.notifications,
                        onPressed: () => _comingSoon(context),
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: context.colors.primary,
                        child: Text(
                          name.isEmpty ? '?' : name.characters.first,
                          style: context.text.titleMedium?.copyWith(
                            color: context.colors.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: AppSpacing.screenPadding,
                  child: HomeHeroCard(
                    onSearch: () => context.go(AppRoutes.explore),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Padding(
                  padding: AppSpacing.screenPadding,
                  child: SectionHeader(
                    title: l10n.homeExplore,
                    actionLabel: l10n.seeAll,
                    onAction: () => context.go(AppRoutes.explore),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  height: 104,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    itemCount: categories.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.xs),
                    itemBuilder: (context, i) {
                      final (icon, label, route) = categories.elementAt(i);
                      return CategoryTile(
                        icon: icon,
                        label: label,
                        highlighted: i == 0,
                        onTap: () => context.go(route),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: AppSpacing.screenPadding,
                  child: SectionHeader(
                    title: l10n.homeCurated,
                    actionLabel: l10n.seeAll,
                    onAction: () => context.go(AppRoutes.explore),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  height: 214,
                  child: switch (curated) {
                    AsyncData(:final value) => ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: AppSpacing.screenPadding,
                      itemCount: value.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: AppSpacing.md),
                      itemBuilder: (context, i) {
                        final place = value.elementAt(i);
                        return CuratedPlaceCard(
                          place: place,
                          onBookmark: () => ref
                              .read(homeViewModelProvider.notifier)
                              .toggleBookmark(place.id),
                        );
                      },
                    ),
                    AsyncError() => ErrorState(
                      message: l10n.errorUnknown,
                      onRetry: () => ref.invalidate(homeViewModelProvider),
                    ),
                    _ => ListView(
                      scrollDirection: Axis.horizontal,
                      padding: AppSpacing.screenPadding,
                      children: const [
                        SkeletonBox(width: 220, height: 142),
                        SizedBox(width: AppSpacing.md),
                        SkeletonBox(width: 220, height: 142),
                      ],
                    ),
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: AppSpacing.screenPadding,
                  child: StoryCard(onTap: () => context.go(AppRoutes.culture)),
                ),
                const SizedBox(height: AppSpacing.xl),
                Padding(
                  padding: AppSpacing.screenPadding,
                  child: SectionHeader(
                    title: l10n.homeGuides,
                    actionLabel: l10n.seeAll,
                    onAction: () => context.go(AppRoutes.guides),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Padding(
                  padding: AppSpacing.screenPadding,
                  child: GuideCard(onTap: () => context.go(AppRoutes.guides)),
                ),
                const SizedBox(height: AppSpacing.xl),
                Padding(
                  padding: AppSpacing.screenPadding,
                  child: ContributeCard(
                    onAddActivity: () => _comingSoon(context),
                    onReportPlace: () => _comingSoon(context),
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
