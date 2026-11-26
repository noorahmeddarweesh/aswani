import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../community_providers.dart';
import '../../domain/entities/post.dart';
import 'community_feed_view_model.dart';
import 'my_posts_view_model.dart';

class PostDetailsState {
  const PostDetailsState({
    required this.post,
    this.comments = const [],
    this.page = 1,
    this.hasMore = false,
    this.sending = false,
  });

  final Post post;
  final List<Comment> comments;
  final int page;
  final bool hasMore;

  /// A comment is being sent.
  final bool sending;

  PostDetailsState copyWith({
    Post? post,
    List<Comment>? comments,
    int? page,
    bool? hasMore,
    bool? sending,
  }) => PostDetailsState(
    post: post ?? this.post,
    comments: comments ?? this.comments,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    sending: sending ?? this.sending,
  );
}

/// One post with its comments. Every change is also put in the feed and in
/// My posts, so going back shows the same numbers.
class PostDetailsViewModel extends AsyncNotifier<PostDetailsState> {
  PostDetailsViewModel(this.postId);

  final String postId;

  @override
  Future<PostDetailsState> build() async {
    final repo = ref.read(communityRepositoryProvider);
    final (post, comments) = await (
      repo.getPost(postId),
      repo.getComments(postId),
    ).wait;
    final value = switch (post) {
      Success(:final value) => value,
      Error(:final failure) => throw failure,
    };
    return switch (comments) {
      Success(value: final page) => PostDetailsState(
        post: value,
        comments: page.items,
        page: page.page,
        hasMore: page.hasMore,
      ),
      Error() => PostDetailsState(post: value),
    };
  }

  PostDetailsState get _s => state.requireValue;

  void _setPost(Post post) {
    state = AsyncData(_s.copyWith(post: post));
    if (ref.read(communityFeedProvider.exists)) {
      ref.read(communityFeedProvider.notifier).replace(post);
    }
    if (ref.read(myPostsProvider.exists)) {
      ref.read(myPostsProvider.notifier).replace(post);
    }
  }

  Future<String?> toggleLike() async {
    final before = _s.post;
    final liked = !before.isLiked;
    _setPost(
      before.copyWith(
        isLiked: liked,
        likeCount: before.likeCount + (liked ? 1 : -1),
      ),
    );
    final result = await ref
        .read(communityRepositoryProvider)
        .setLiked(postId, liked: liked);
    if (!ref.mounted) return null;
    switch (result) {
      case Success(:final value):
        _setPost(_s.post.copyWith(likeCount: value));
        return null;
      case Error(:final failure):
        _setPost(before);
        return failure.code;
    }
  }

  Future<String?> toggleBookmark() async {
    final before = _s.post;
    _setPost(before.copyWith(isBookmarked: !before.isBookmarked));
    final result = await ref
        .read(communityRepositoryProvider)
        .setBookmarked(postId, saved: !before.isBookmarked);
    if (!ref.mounted) return null;
    if (result case Error(:final failure)) {
      _setPost(before);
      return failure.code;
    }
    return null;
  }

  /// Returns an error code, or null when the comment was posted.
  Future<String?> addComment(String text) async {
    if (text.trim().isEmpty || _s.sending) return null;
    state = AsyncData(_s.copyWith(sending: true));
    final result = await ref
        .read(communityRepositoryProvider)
        .addComment(postId, text.trim());
    if (!ref.mounted) return null;
    switch (result) {
      case Success(:final value):
        state = AsyncData(
          _s.copyWith(comments: [..._s.comments, value], sending: false),
        );
        _setPost(_s.post.copyWith(commentCount: _s.post.commentCount + 1));
        return null;
      case Error(:final failure):
        state = AsyncData(_s.copyWith(sending: false));
        return failure.code;
    }
  }

  Future<String?> deleteComment(String commentId) async {
    final result = await ref
        .read(communityRepositoryProvider)
        .deleteComment(commentId);
    if (!ref.mounted) return null;
    switch (result) {
      case Success():
        state = AsyncData(
          _s.copyWith(
            comments: _s.comments.where((c) => c.id != commentId).toList(),
          ),
        );
        _setPost(_s.post.copyWith(commentCount: _s.post.commentCount - 1));
        return null;
      case Error(:final failure):
        return failure.code;
    }
  }

  Future<void> loadMoreComments() async {
    if (!_s.hasMore) return;
    final result = await ref
        .read(communityRepositoryProvider)
        .getComments(postId, page: _s.page + 1);
    if (!ref.mounted) return;
    if (result case Success(:final value)) {
      state = AsyncData(
        _s.copyWith(
          comments: [..._s.comments, ...value.items],
          page: value.page,
          hasMore: value.hasMore,
        ),
      );
    }
  }

  /// Returns an error code, or null when the post was deleted.
  Future<String?> deletePost() async {
    final result = await ref
        .read(communityRepositoryProvider)
        .deletePost(postId);
    switch (result) {
      case Success():
        if (ref.read(communityFeedProvider.exists)) {
          ref.read(communityFeedProvider.notifier).remove(postId);
        }
        if (ref.read(myPostsProvider.exists)) {
          ref.read(myPostsProvider.notifier).remove(postId);
        }
        return null;
      case Error(:final failure):
        return failure.code;
    }
  }
}

final postDetailsProvider = AsyncNotifierProvider.autoDispose
    .family<PostDetailsViewModel, PostDetailsState, String>(
      PostDetailsViewModel.new,
    );
