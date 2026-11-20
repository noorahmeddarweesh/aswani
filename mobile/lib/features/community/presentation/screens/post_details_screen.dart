import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/responsive/window_size.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/bookmark_icon.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../domain/entities/post.dart';
import '../viewmodels/post_details_view_model.dart';
import '../widgets/comment_widgets.dart';
import '../widgets/likes_sheet.dart';
import '../widgets/post_actions.dart';
import '../widgets/post_widgets.dart';

/// "From the community": the photos, the caption, appreciations, the
/// comment box and the comments.
class PostDetailsScreen extends ConsumerStatefulWidget {
  const PostDetailsScreen({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends ConsumerState<PostDetailsScreen> {
  final _comment = FocusNode();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _comment.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Shows the comment just posted, at the end of the list.
  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: AppMotion.medium,
        curve: AppMotion.standard,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = postDetailsProvider(widget.postId);
    final details = ref.watch(provider);
    final vm = ref.read(provider.notifier);
    final session = ref.watch(sessionProvider);
    final mine = details.value?.post.author.id == session?.userId;

    Future<void> delete() async {
      if (!await PostUi.confirmDeletePost(context)) return;
      final error = await vm.deletePost();
      if (!context.mounted) return;
      if (error != null) return PostUi.showError(context, error);
      final messenger = ScaffoldMessenger.of(context);
      context.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.communityPostDeleted)),
      );
    }

    return Scaffold(
      appBar: AppTopBar(
        title: l10n.communityPostTitle,
        trailing: details.hasValue
            ? PostMenu(onDelete: mine ? delete : null, filled: true)
            : null,
      ),
      body: details.when(
        skipLoadingOnReload: true,
        loading: () => const Padding(
          padding: AppSpacing.screenPadding,
          child: PostCardSkeleton(),
        ),
        error: (error, _) => ErrorState(
          message: l10n.errorFor(
            error is Failure ? error.code : ErrorCodes.unknown,
          ),
          onRetry: () => ref.invalidate(provider),
        ),
        data: (state) => MaxWidthBox(
          maxWidth: 640,
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.extentAfter < 300) vm.loadMoreComments();
              return false;
            },
            // As in the design: the comment box sits under the post, and
            // the comments follow it, newest last.
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              children: [
                LikeOnDoubleTap(
                  liked: state.post.isLiked,
                  onLike: () => PostUi.report(context, vm.toggleLike()),
                  child: PostImages(images: state.post.images, aspectRatio: 1),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.screen,
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.xs,
                  ),
                  child: PostAuthorRow(
                    post: state.post,
                    avatarSize: 40,
                    trailing: PostAction(
                      icon: Icon(
                        LucideIcons.share2,
                        size: 22,
                        color: context.colors.primary,
                      ),
                      tooltip: l10n.share,
                      onPressed: () => PostUi.share(context, state.post),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screen,
                  ),
                  child: CaptionText(state.post.caption),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: _Counts(
                    post: state.post,
                    onLike: () => PostUi.report(context, vm.toggleLike()),
                    onLikes: () => showLikesSheet(context, state.post.id),
                    onComment: _comment.requestFocus,
                    onBookmark: () =>
                        PostUi.report(context, vm.toggleBookmark()),
                  ),
                ),
                CommentComposer(
                  name: session?.displayName ?? '',
                  avatarUrl: session?.avatarUrl,
                  sending: state.sending,
                  focusNode: _comment,
                  onSend: (text) async {
                    final error = await vm.addComment(text);
                    if (!context.mounted) return false;
                    PostUi.showError(context, error);
                    if (error == null) _scrollToEnd();
                    return error == null;
                  },
                ),
                const SizedBox(height: AppSpacing.xs),
                if (state.comments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screen,
                    ),
                    child: Text(
                      l10n.communityNoComments,
                      style: context.text.bodySmall,
                    ),
                  ),
                for (final comment in state.comments)
                  CommentTile(
                    comment: comment,
                    onDelete: comment.author.id == session?.userId
                        ? () async {
                            if (!await PostUi.confirmDeleteComment(context)) {
                              return;
                            }
                            if (!context.mounted) return;
                            await PostUi.report(
                              context,
                              vm.deleteComment(comment.id),
                            );
                          }
                        : null,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Counts extends StatelessWidget {
  const _Counts({
    required this.post,
    required this.onLike,
    required this.onLikes,
    required this.onComment,
    required this.onBookmark,
  });

  final Post post;
  final VoidCallback onLike;

  /// Opens who liked the post.
  final VoidCallback onLikes;
  final VoidCallback onComment;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        PostAction(
          icon: LikeIcon(liked: post.isLiked, size: 20),
          tooltip: post.isLiked ? l10n.communityUnlike : l10n.communityLike,
          onPressed: onLike,
        ),
        // The number opens who liked it, as in Instagram.
        Semantics(
          button: true,
          label: l10n.communityAppreciations(post.likeCount),
          excludeSemantics: true,
          child: InkWell(
            borderRadius: AppRadii.smAll,
            onTap: onLikes,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSpacing.minTouchTarget,
                minWidth: 32,
              ),
              child: Center(
                child: Text(
                  '${post.likeCount}',
                  style: context.text.bodySmall?.copyWith(
                    color: context.palette.ink,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xxs),
        PostAction(
          icon: Icon(
            LucideIcons.messageCircle,
            size: 20,
            color: context.palette.ink,
          ),
          tooltip: l10n.communityComment,
          label: '${post.commentCount}',
          onPressed: onComment,
        ),
        const Spacer(),
        PostAction(
          icon: BookmarkIcon(saved: post.isBookmarked),
          tooltip: post.isBookmarked
              ? l10n.communityUnsave
              : l10n.communitySave,
          onPressed: onBookmark,
        ),
      ],
    );
  }
}
