import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/pagination/paged.dart';
import '../../../../core/result/result.dart';
import '../../community_providers.dart';
import '../../domain/entities/post.dart';

/// Who appreciated a post (GET /community/posts/{id}/likes), page by page.
class PostLikesViewModel extends AsyncNotifier<Paged<Author>> {
  PostLikesViewModel(this.postId);

  final String postId;
  bool _loading = false;

  @override
  Future<Paged<Author>> build() async =>
      switch (await ref.read(communityRepositoryProvider).getLikes(postId)) {
        Success(:final value) => value,
        Error(:final failure) => throw failure,
      };

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || _loading) return;
    _loading = true;
    final result = await ref
        .read(communityRepositoryProvider)
        .getLikes(postId, page: current.page + 1);
    _loading = false;
    if (!ref.mounted) return;
    if (result case Success(:final value)) {
      state = AsyncData(
        Paged(
          items: [...current.items, ...value.items],
          page: value.page,
          totalPages: value.totalPages,
          total: value.total,
        ),
      );
    }
  }
}

final postLikesProvider = AsyncNotifierProvider.autoDispose
    .family<PostLikesViewModel, Paged<Author>, String>(PostLikesViewModel.new);

/// The story viewer of one highlight: the most appreciated moments of its
/// category in the last 7 days (contract v0.3, `sort=top`).
final highlightMomentsProvider = FutureProvider.autoDispose
    .family<List<Post>, PostCategory>((ref, category) async {
      final result = await ref
          .read(communityRepositoryProvider)
          .getPosts(category: category, sort: PostSort.top, limit: 10);
      return switch (result) {
        Success(:final value) => value.items,
        Error(:final failure) => throw failure,
      };
    });
