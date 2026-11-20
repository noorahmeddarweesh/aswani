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
import '../viewmodels/culture_view_models.dart';
import '../widgets/culture_widgets.dart';

/// "Saved reads": stories the user saved. Un-saving one hides it at once.
class SavedReadsScreen extends ConsumerWidget {
  const SavedReadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final saved = ref.watch(savedStoriesProvider);
    ref.watch(storySavesProvider);
    final saves = ref.read(storySavesProvider.notifier);

    return Scaffold(
      appBar: AppTopBar(title: l10n.cultureSavedReads),
      body: MaxWidthBox(
        child: saved.when(
          skipLoadingOnReload: true,
          loading: () => const Padding(
            padding: AppSpacing.screenPadding,
            child: StoryListSkeleton(),
          ),
          error: (error, _) => ErrorState(
            message: l10n.errorFor(
              error is Failure ? error.code : ErrorCodes.unknown,
            ),
            onRetry: () => ref.invalidate(savedStoriesProvider),
          ),
          data: (page) {
            final items = page.items.where(saves.isSaved).toList();
            if (items.isEmpty) {
              return EmptyState(
                message: l10n.cultureSavedEmpty,
                icon: LucideIcons.bookmark,
              );
            }
            return ListView(
              padding: AppSpacing.screenPadding.copyWith(
                bottom: AppSpacing.xxl,
              ),
              children: staggered([
                for (final story in items)
                  StoryListTile(
                    story: story,
                    onTap: () => context.push(CultureRoutes.story(story.id)),
                  ),
              ]),
            );
          },
        ),
      ),
    );
  }
}
