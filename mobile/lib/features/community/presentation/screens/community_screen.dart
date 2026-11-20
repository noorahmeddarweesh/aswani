import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/responsive/window_size.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/motion.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../community_routes.dart';
import '../../domain/entities/post.dart';
import '../viewmodels/community_feed_view_model.dart';
import '../widgets/highlights_row.dart';
import '../widgets/post_actions.dart';
import '../widgets/post_widgets.dart';

/// Community tab: highlights on top, then the posts, newest first. Pull to
/// refresh; the next page loads near the end of the list.
class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final feed = ref.watch(communityFeedProvider);
    final vm = ref.read(communityFeedProvider.notifier);
    final me = ref.watch(sessionProvider)?.userId;
    final state = feed.value;

    void newPost() => context.push(CommunityRoutes.newPost);

    Widget postCard(Post post) => PostCard(
      post: post,
      onOpen: () => context.push(CommunityRoutes.post(post.id)),
      onLike: () => PostUi.report(context, vm.toggleLike(post.id)),
      onBookmark: () => PostUi.report(context, vm.toggleBookmark(post.id)),
      onShare: () => PostUi.share(context, post),
      onDelete: post.author.id == me
          ? () async {
              if (!await PostUi.confirmDeletePost(context)) return;
              final error = await vm.deletePost(post.id);
              if (!context.mounted) return;
              error == null
                  ? PostUi.showMessage(context, l10n.communityPostDeleted)
                  : PostUi.showError(context, error);
            }
          : null,
    );

    final List<Widget> body;
    if (state == null && feed.hasError) {
      body = [
        const SizedBox(height: AppSpacing.xxxl),
        ErrorState(
          message: l10n.errorFor(feedErrorCode(feed.error!)),
          onRetry: vm.refresh,
        ),
      ];
    } else if (state == null || state.loadingPosts) {
      body = [
        if (state != null)
          HighlightsRow(
            highlights: state.highlights,
            selected: state.category,
            onSelect: vm.selectCategory,
            onNewPost: newPost,
          )
        else
          const SizedBox(height: 94),
        for (var i = 0; i < 2; i++)
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.md,
              AppSpacing.screen,
              0,
            ),
            child: PostCardSkeleton(),
          ),
      ];
    } else {
      body = [
        HighlightsRow(
          highlights: state.highlights,
          selected: state.category,
          onSelect: vm.selectCategory,
          onNewPost: newPost,
        ),
        if (state.errorCode != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxl),
            child: ErrorState(
              message: l10n.errorFor(state.errorCode!),
              onRetry: vm.refresh,
            ),
          )
        else if (state.posts.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxl),
            child: EmptyState(
              message: l10n.communityEmpty,
              icon: LucideIcons.images,
            ),
          ),
        ...staggered([
          for (final post in state.posts)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                0,
              ),
              child: postCard(post),
            ),
        ]),
        if (state.loadingMore)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Center(child: CircularProgressIndicator()),
          ),
      ];
    }

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'community-new-post',
        tooltip: l10n.communityNewPost,
        backgroundColor: context.palette.surfaceMuted,
        foregroundColor: context.colors.primary,
        elevation: 0,
        shape: const CircleBorder(),
        onPressed: newPost,
        child: const Icon(LucideIcons.plus),
      ),
      body: SafeArea(
        child: MaxWidthBox(
          maxWidth: 640,
          child: RefreshIndicator(
            onRefresh: vm.refresh,
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n.metrics.extentAfter < 600) vm.loadMore();
                return false;
              },
              child: ListView(
                padding: const EdgeInsets.only(
                  top: AppSpacing.md,
                  bottom: AppSpacing.xxxl * 2,
                ),
                children: body,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
