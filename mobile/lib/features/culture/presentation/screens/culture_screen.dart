import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/responsive/window_size.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/motion.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../culture_routes.dart';
import '../viewmodels/culture_view_models.dart';
import '../widgets/culture_widgets.dart';

/// Culture tab: the featured story, themes and selected reads.
class CultureScreen extends ConsumerWidget {
  const CultureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final home = ref.watch(cultureHomeProvider);
    final wide = context.windowSize != WindowSize.compact;

    final List<Widget> children = home.when(
      skipLoadingOnReload: true,
      loading: () => [
        const AspectRatio(aspectRatio: 1.18, child: SkeletonBox()),
        const SizedBox(height: AppSpacing.lg),
        const StoryListSkeleton(),
      ],
      error: (error, _) => [
        const SizedBox(height: AppSpacing.xxxl),
        ErrorState(
          message: l10n.errorFor(
            error is Failure ? error.code : ErrorCodes.unknown,
          ),
          onRetry: () => ref.invalidate(cultureHomeProvider),
        ),
      ],
      data: (data) => staggered([
        FeaturedStoryCard(
          story: data.featured,
          onTap: () => context.push(CultureRoutes.story(data.featured.id)),
        ),
        const SizedBox(height: AppSpacing.lg),
        SectionHeader(
          title: l10n.cultureBrowseByTheme,
          actionLabel: l10n.seeAll,
          onAction: () => context.push(CultureRoutes.stories()),
        ),
        const SizedBox(height: AppSpacing.sm),
        GridView.count(
          crossAxisCount: wide ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.42,
          children: [
            for (final theme in data.themes)
              ThemeTile(
                title: theme.title(lang),
                image: theme.image,
                onTap: () => context.push(CultureRoutes.stories(theme.theme)),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        SectionHeader(
          title: l10n.cultureSelectedReads,
          actionLabel: l10n.cultureSaved,
          onAction: () => context.push(CultureRoutes.saved),
        ),
        const SizedBox(height: AppSpacing.xs),
        for (final story in data.selectedReads)
          StoryListTile(
            story: story,
            onTap: () => context.push(CultureRoutes.story(story.id)),
          ),
      ]),
    );

    return Scaffold(
      body: SafeArea(
        child: MaxWidthBox(
          child: RefreshIndicator(
            onRefresh: () => ref.refresh(cultureHomeProvider.future),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xxl,
              ),
              children: [const CultureHeader(), ...children],
            ),
          ),
        ),
      ),
    );
  }
}
