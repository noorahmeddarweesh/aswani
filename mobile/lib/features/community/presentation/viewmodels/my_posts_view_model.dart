import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/pagination/paged.dart';
import '../../../../core/result/result.dart';
import '../../community_providers.dart';
import '../../domain/entities/post.dart';
import 'community_feed_view_model.dart';

/// "My posts" (Profile): the signed-in user's posts, newest first.
class MyPostsViewModel extends AsyncNotifier<Paged<Post>> {
  @override
  Future<Paged<Post>> build() async {
    final result = await ref.read(communityRepositoryProvider).getMyPosts();
    return switch (result) {
      Success(:final value) => value,
      Error(:final failure) => throw failure,
    };
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore) return;
    final result = await ref
        .read(communityRepositoryProvider)
        .getMyPosts(page: current.page + 1);
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

  void _edit(List<Post> Function(List<Post>) change) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      Paged(
        items: change(current.items),
        page: current.page,
        totalPages: current.totalPages,
        total: current.total,
      ),
    );
  }

  void replace(Post post) =>
      _edit((items) => [for (final p in items) p.id == post.id ? post : p]);

  void remove(String id) =>
      _edit((items) => items.where((p) => p.id != id).toList());

  void insertFirst(Post post) => _edit((items) => [post, ...items]);

  Post? _find(String id) =>
      state.value?.items.where((p) => p.id == id).firstOrNull;

  void _sync(Post post) {
    replace(post);
    if (ref.read(communityFeedProvider.exists)) {
      ref.read(communityFeedProvider.notifier).replace(post);
    }
  }

  /// Same as in the feed: changes at once, rolls back if the call fails.
  Future<String?> toggleLike(String id) async {
    final post = _find(id);
    if (post == null) return null;
    final liked = !post.isLiked;
    _sync(
      post.copyWith(
        isLiked: liked,
        likeCount: post.likeCount + (liked ? 1 : -1),
      ),
    );
    final result = await ref
        .read(communityRepositoryProvider)
        .setLiked(id, liked: liked);
    if (!ref.mounted) return null;
    switch (result) {
      case Success(:final value):
        final now = _find(id);
        if (now != null) _sync(now.copyWith(likeCount: value));
        return null;
      case Error(:final failure):
        _sync(post);
        return failure.code;
    }
  }

  Future<String?> toggleBookmark(String id) async {
    final post = _find(id);
    if (post == null) return null;
    _sync(post.copyWith(isBookmarked: !post.isBookmarked));
    final result = await ref
        .read(communityRepositoryProvider)
        .setBookmarked(id, saved: !post.isBookmarked);
    if (!ref.mounted) return null;
    if (result case Error(:final failure)) {
      _sync(post);
      return failure.code;
    }
    return null;
  }

  Future<String?> deletePost(String id) async {
    final result = await ref.read(communityRepositoryProvider).deletePost(id);
    if (!ref.mounted) return null;
    switch (result) {
      case Success():
        remove(id);
        if (ref.read(communityFeedProvider.exists)) {
          ref.read(communityFeedProvider.notifier).remove(id);
        }
        return null;
      case Error(:final failure):
        return failure.code;
    }
  }
}

final myPostsProvider =
    AsyncNotifierProvider.autoDispose<MyPostsViewModel, Paged<Post>>(
      MyPostsViewModel.new,
    );
