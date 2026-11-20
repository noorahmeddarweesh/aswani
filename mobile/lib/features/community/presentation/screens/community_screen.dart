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
import '../widgets/comments_sheet.dart';
import '../widgets/community_header.dart';
import '../widgets/highlights_row.dart';
import '../widgets/likes_sheet.dart';
import '../widgets/post_actions.dart';
import '../widgets/post_widgets.dart';

/// Community tab, Instagram-style: the header hides as the feed scrolls
/// down and comes back on a small scroll up; the story circles scroll with
/// the posts. Pull to refresh; the next page loads near the end.
class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  Future<void> _newMoment(BuildContext context) async {
    final l10n = context.l10n;
    final source = await showModalBottomSheet<MomentSource>(
      context: context,
      useSafeArea: true,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.communityYourMoment, style: context.text.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            ListTile(
              leading: Icon(LucideIcons.camera, color: context.palette.link),
              title: Text(l10n.communityMomentCamera),
              onTap: () => Navigator.pop(context, MomentSource.camera),
            ),
            ListTile(
              leading: Icon(LucideIcons.images, color: context.palette.link),
              title: Text(l10n.communityMomentGallery),
              onTap: () => Navigator.pop(context, MomentSource.gallery),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
    if (source != null && context.mounted) {
      await context.push(CommunityRoutes.newMoment(source));
    }
  }

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
      onComments: () => showCommentsSheet(context, post.id),
      onLikes: () => showLikesSheet(context, post.id),
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

    Widget padded(Widget child) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.sm,
        AppSpacing.screen,
        0,
      ),
      child: child,
    );

    final stories = state == null
        ? const SizedBox(height: HighlightsRow.circle + 40)
        : HighlightsRow(
            highlights: state.highlights,
            onOpen: (h) => context.push(CommunityRoutes.highlight(h.id)),
            onNewMoment: () => _newMoment(context),
          );

    final List<Widget> posts;
    if (state == null && feed.hasError) {
      posts = [
        const SizedBox(height: AppSpacing.xxl),
        ErrorState(
          message: l10n.errorFor(feedErrorCode(feed.error!)),
          onRetry: vm.refresh,
        ),
      ];
    } else if (state == null || state.loadingPosts) {
      posts = [for (var i = 0; i < 2; i++) padded(const PostCardSkeleton())];
    } else if (state.errorCode != null) {
      posts = [
        const SizedBox(height: AppSpacing.xxl),
        ErrorState(
          message: l10n.errorFor(state.errorCode!),
          onRetry: vm.refresh,
        ),
      ];
    } else if (state.posts.isEmpty) {
      posts = [
        const SizedBox(height: AppSpacing.xxl),
        EmptyState(message: l10n.communityEmpty, icon: LucideIcons.images),
      ];
    } else {
      posts = [
        ...staggered([for (final post in state.posts) padded(postCard(post))]),
        if (state.loadingMore)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Center(child: CircularProgressIndicator()),
          ),
      ];
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: MaxWidthBox(
          maxWidth: 640,
          child: RefreshIndicator(
            onRefresh: vm.refresh,
            // Below the header, so the spinner is not hidden by it.
            edgeOffset: 88,
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n.metrics.extentAfter < 600) vm.loadMore();
                return false;
              },
              child: CustomScrollView(
                slivers: [
                  SliverFloatingHeader(
                    child: CommunityHeader(onNewPost: newPost),
                  ),
                  SliverToBoxAdapter(child: stories),
                  SliverList.list(children: posts),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.xxxl),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
