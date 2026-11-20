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
import '../../community_routes.dart';
import '../viewmodels/my_posts_view_model.dart';
import '../widgets/comments_sheet.dart';
import '../widgets/likes_sheet.dart';
import '../widgets/post_actions.dart';
import '../widgets/post_widgets.dart';

/// "My posts" (from Profile): the user's own posts.
class MyPostsScreen extends ConsumerWidget {
  const MyPostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final posts = ref.watch(myPostsProvider);
    final vm = ref.read(myPostsProvider.notifier);

    return Scaffold(
      appBar: AppTopBar(title: l10n.communityMyPosts),
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'my-posts-new-post',
        tooltip: l10n.communityNewPost,
        onPressed: () => context.push(CommunityRoutes.newPost),
        child: const Icon(LucideIcons.plus),
      ),
      body: MaxWidthBox(
        maxWidth: 640,
        child: posts.when(
          skipLoadingOnReload: true,
          loading: () => const Padding(
            padding: AppSpacing.screenPadding,
            child: PostCardSkeleton(),
          ),
          error: (error, _) => ErrorState(
            message: l10n.errorFor(
              error is Failure ? error.code : ErrorCodes.unknown,
            ),
            onRetry: () => ref.invalidate(myPostsProvider),
          ),
          data: (page) => page.items.isEmpty
              ? EmptyState(
                  message: l10n.communityMyPostsEmpty,
                  icon: LucideIcons.images,
                )
              : RefreshIndicator(
                  onRefresh: () => ref.refresh(myPostsProvider.future),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      if (n.metrics.extentAfter < 600) vm.loadMore();
                      return false;
                    },
                    child: ListView(
                      padding: AppSpacing.screenPadding.copyWith(
                        bottom: AppSpacing.xxxl * 2,
                      ),
                      children: staggered([
                        for (final post in page.items)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: PostCard(
                              post: post,
                              onOpen: () =>
                                  context.push(CommunityRoutes.post(post.id)),
                              onLike: () => PostUi.report(
                                context,
                                vm.toggleLike(post.id),
                              ),
                              onBookmark: () => PostUi.report(
                                context,
                                vm.toggleBookmark(post.id),
                              ),
                              onShare: () => PostUi.share(context, post),
                              onComments: () =>
                                  showCommentsSheet(context, post.id),
                              onLikes: () => showLikesSheet(context, post.id),
                              onDelete: () async {
                                if (!await PostUi.confirmDeletePost(context)) {
                                  return;
                                }
                                final error = await vm.deletePost(post.id);
                                if (!context.mounted) return;
                                error == null
                                    ? PostUi.showMessage(
                                        context,
                                        l10n.communityPostDeleted,
                                      )
                                    : PostUi.showError(context, error);
                              },
                            ),
                          ),
                      ]),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
