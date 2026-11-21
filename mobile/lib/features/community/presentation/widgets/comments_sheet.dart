import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/state_views.dart';
import '../viewmodels/post_details_view_model.dart';
import 'comment_widgets.dart';
import 'post_actions.dart';

/// The comment icon opens the comments over the feed, as in Instagram:
/// drag it up for more, write at the bottom.
Future<void> showCommentsSheet(BuildContext context, String postId) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      // Over the tab bar too, as in Instagram.
      useRootNavigator: true,
      showDragHandle: true,
      builder: (context) => Padding(
        // Keeps the box above the keyboard.
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scroll) =>
              _CommentsSheet(postId: postId, scroll: scroll),
        ),
      ),
    );

class _CommentsSheet extends ConsumerWidget {
  const _CommentsSheet({required this.postId, required this.scroll});

  final String postId;
  final ScrollController scroll;

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scroll.hasClients) return;
      scroll.animateTo(
        scroll.position.maxScrollExtent,
        duration: AppMotion.medium,
        curve: AppMotion.standard,
      );
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final provider = postDetailsProvider(postId);
    final details = ref.watch(provider);
    final session = ref.watch(sessionProvider);

    return Column(
      children: [
        Text(l10n.communityComments, style: context.text.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        const Divider(height: 1),
        Expanded(
          child: details.when(
            skipLoadingOnReload: true,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ErrorState(
              message: l10n.errorFor(
                error is Failure ? error.code : ErrorCodes.unknown,
              ),
              onRetry: () => ref.invalidate(provider),
            ),
            data: (state) => state.comments.isEmpty
                ? ListView(
                    controller: scroll,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Text(
                          l10n.communityNoComments,
                          textAlign: TextAlign.center,
                          style: context.text.bodyMedium,
                        ),
                      ),
                    ],
                  )
                : NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      if (n.metrics.extentAfter < 300) {
                        ref.read(provider.notifier).loadMoreComments();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      controller: scroll,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      itemCount: state.comments.length,
                      itemBuilder: (context, i) {
                        final comment = state.comments[i];
                        return CommentTile(
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
                                    ref
                                        .read(provider.notifier)
                                        .deleteComment(comment.id),
                                  );
                                }
                              : null,
                        );
                      },
                    ),
                  ),
          ),
        ),
        CommentComposer(
          name: session?.displayName ?? '',
          avatarUrl: session?.avatarUrl,
          sending: details.value?.sending ?? false,
          quickEmojis: true,
          onSend: (text) async {
            if (!details.hasValue) return false;
            final error = await ref.read(provider.notifier).addComment(text);
            if (!context.mounted) return false;
            PostUi.showError(context, error);
            if (error == null) _scrollToEnd();
            return error == null;
          },
        ),
      ],
    );
  }
}
