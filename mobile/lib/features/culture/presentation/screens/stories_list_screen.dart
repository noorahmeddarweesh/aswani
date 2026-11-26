import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/responsive/window_size.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/motion.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../culture_routes.dart';
import '../../domain/entities/story.dart';
import '../viewmodels/culture_view_models.dart';
import '../widgets/culture_widgets.dart';

/// Stories of a theme ("Browse by theme"), or all stories ("See all"),
/// with theme chips to switch.
class StoriesListScreen extends ConsumerStatefulWidget {
  const StoriesListScreen({super.key, this.theme});

  final CultureTheme? theme;

  @override
  ConsumerState<StoriesListScreen> createState() => _StoriesListScreenState();
}

class _StoriesListScreenState extends ConsumerState<StoriesListScreen> {
  late CultureTheme? _theme = widget.theme;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = storiesListProvider(_theme);
    final stories = ref.watch(provider);

    return Scaffold(
      appBar: AppTopBar(title: _theme?.label(l10n) ?? l10n.cultureAllStories),
      body: MaxWidthBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: [
                  for (final theme in [null, ...CultureTheme.values])
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        end: AppSpacing.xs,
                      ),
                      child: ChoiceChip(
                        label: Text(theme?.label(l10n) ?? l10n.filterAll),
                        selected: theme == _theme,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _theme = theme),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: stories.when(
                skipLoadingOnReload: true,
                loading: () => const Padding(
                  padding: AppSpacing.screenPadding,
                  child: StoryListSkeleton(count: 4),
                ),
                error: (error, _) => ErrorState(
                  message: l10n.errorFor(
                    error is Failure ? error.code : ErrorCodes.unknown,
                  ),
                  onRetry: () => ref.invalidate(provider),
                ),
                data: (page) => page.items.isEmpty
                    ? EmptyState(
                        message: l10n.cultureEmpty,
                        icon: LucideIcons.bookOpen,
                      )
                    : NotificationListener<ScrollNotification>(
                        onNotification: (n) {
                          if (n.metrics.extentAfter < 400) {
                            ref.read(provider.notifier).loadMore();
                          }
                          return false;
                        },
                        child: ListView(
                          padding: AppSpacing.screenPadding.copyWith(
                            bottom: AppSpacing.xxl,
                          ),
                          children: staggered([
                            for (final story in page.items)
                              StoryListTile(
                                story: story,
                                onTap: () =>
                                    context.push(CultureRoutes.story(story.id)),
                              ),
                          ]),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
