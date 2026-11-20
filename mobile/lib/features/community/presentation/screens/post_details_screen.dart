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
import '../../../../shared/utils/relative_time.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/bookmark_icon.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../domain/entities/post.dart';
import '../viewmodels/post_details_view_model.dart';
import '../widgets/post_actions.dart';
import '../widgets/post_widgets.dart';

/// "Community post": the photos, the caption, appreciations and comments,
/// with the comment box at the bottom.
class PostDetailsScreen extends ConsumerStatefulWidget {
  const PostDetailsScreen({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends ConsumerState<PostDetailsScreen> {
  final _scroll = ScrollController();

  @override
  void dispose() {
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
        trailing: mine ? PostMenu(onDelete: delete) : null,
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
          child: Column(
            children: [
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n.metrics.extentAfter < 300) vm.loadMoreComments();
                    return false;
                  },
                  child: ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    children: [
                      PostImages(images: state.post.images, aspectRatio: 1),
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
                          onBookmark: () =>
                              PostUi.report(context, vm.toggleBookmark()),
                        ),
                      ),
                      const Divider(
                        indent: AppSpacing.screen,
                        endIndent: AppSpacing.screen,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screen,
                          AppSpacing.sm,
                          AppSpacing.screen,
                          AppSpacing.xs,
                        ),
                        child: Text(
                          l10n.communityComments,
                          style: context.text.titleSmall,
                        ),
                      ),
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
                        _CommentTile(
                          comment: comment,
                          onDelete: comment.author.id == session?.userId
                              ? () async {
                                  if (!await PostUi.confirmDeleteComment(
                                    context,
                                  )) {
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
              _CommentComposer(
                name: session?.displayName ?? '',
                avatarUrl: session?.avatarUrl,
                sending: state.sending,
                onSend: (text) async {
                  final error = await vm.addComment(text);
                  if (!context.mounted) return false;
                  PostUi.showError(context, error);
                  if (error == null) _scrollToEnd();
                  return error == null;
                },
              ),
            ],
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
    required this.onBookmark,
  });

  final Post post;
  final VoidCallback onLike;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        PostAction(
          icon: LikeIcon(liked: post.isLiked, size: 20),
          tooltip: post.isLiked ? l10n.communityUnlike : l10n.communityLike,
          label: '${post.likeCount}',
          onPressed: onLike,
        ),
        PostAction(
          icon: Icon(
            LucideIcons.messageCircle,
            size: 20,
            color: context.palette.ink,
          ),
          tooltip: l10n.communityComments,
          label: '${post.commentCount}',
          onPressed: () {},
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

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment, this.onDelete});

  final Comment comment;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onDelete,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screen,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(
              name: comment.author.fullName,
              imageUrl: comment.author.avatarUrl,
              size: 32,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.author.fullName,
                    style: context.text.bodySmall?.copyWith(
                      fontSize: 12,
                      color: context.palette.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    comment.text,
                    style: context.text.bodyMedium?.copyWith(fontSize: 13),
                  ),
                  Text(
                    relativeTime(context.l10n, comment.createdAt),
                    style: context.text.labelSmall?.copyWith(
                      color: context.palette.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(
                tooltip: context.l10n.communityDeleteComment,
                icon: Icon(
                  LucideIcons.trash2,
                  size: 16,
                  color: context.palette.textTertiary,
                ),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}

class _CommentComposer extends StatefulWidget {
  const _CommentComposer({
    required this.name,
    required this.avatarUrl,
    required this.sending,
    required this.onSend,
  });

  final String name;
  final String? avatarUrl;
  final bool sending;

  /// Returns true when the comment was posted (the box is then cleared).
  final Future<bool> Function(String text) onSend;

  @override
  State<_CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<_CommentComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text;
    if (text.trim().isEmpty || widget.sending) return;
    if (await widget.onSend(text)) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.5,
      child: Material(
        color: context.colors.surface,
        child: SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: palette.border)),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                UserAvatar(
                  name: widget.name,
                  imageUrl: widget.avatarUrl,
                  size: 36,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 1000,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: context.l10n.communityCommentHint,
                      counterText: '',
                      isDense: true,
                      border: const OutlineInputBorder(
                        borderRadius: AppRadii.pillAll,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) {
                    final ready =
                        _controller.text.trim().isNotEmpty && !widget.sending;
                    return IconButton.filled(
                      tooltip: context.l10n.communitySendComment,
                      onPressed: ready ? _send : null,
                      icon: widget.sending
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(LucideIcons.sendHorizontal, size: 18),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
