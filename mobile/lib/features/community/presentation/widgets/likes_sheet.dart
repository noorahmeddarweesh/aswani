import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../viewmodels/post_likes_view_model.dart';

/// "124 appreciations" opens who appreciated the post, as in Instagram.
Future<void> showLikesSheet(BuildContext context, String postId) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      // Over the tab bar too, as in Instagram.
      useRootNavigator: true,
      showDragHandle: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        builder: (context, scroll) =>
            _LikesList(postId: postId, scroll: scroll),
      ),
    );

class _LikesList extends ConsumerWidget {
  const _LikesList({required this.postId, required this.scroll});

  final String postId;
  final ScrollController scroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final likes = ref.watch(postLikesProvider(postId));
    return Column(
      children: [
        Text(l10n.communityLikesTitle, style: context.text.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        const Divider(height: 1),
        Expanded(
          child: likes.when(
            skipLoadingOnReload: true,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ErrorState(
              message: l10n.errorFor(
                error is Failure ? error.code : ErrorCodes.unknown,
              ),
              onRetry: () => ref.invalidate(postLikesProvider(postId)),
            ),
            data: (page) => page.items.isEmpty
                ? EmptyState(
                    message: l10n.communityLikesEmpty,
                    icon: LucideIcons.heart,
                  )
                : NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      if (n.metrics.extentAfter < 300) {
                        ref.read(postLikesProvider(postId).notifier).loadMore();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      controller: scroll,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      itemCount: page.items.length,
                      itemBuilder: (context, i) {
                        final person = page.items[i];
                        return ListTile(
                          leading: UserAvatar(
                            name: person.fullName,
                            imageUrl: person.avatarUrl,
                            size: 40,
                          ),
                          title: Text(
                            person.fullName,
                            style: context.text.titleSmall?.copyWith(
                              color: context.palette.ink,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
