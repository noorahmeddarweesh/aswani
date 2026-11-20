import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../community_providers.dart';
import '../../domain/entities/post.dart';

class FeedState {
  const FeedState({
    this.highlights = const [],
    this.posts = const [],
    this.category,
    this.page = 1,
    this.hasMore = false,
    this.loadingPosts = false,
    this.loadingMore = false,
    this.errorCode,
  });

  final List<Highlight> highlights;
  final List<Post> posts;

  /// The highlight the user tapped; null = all posts.
  final PostCategory? category;
  final int page;
  final bool hasMore;

  /// The list is reloading for a new category (highlights stay).
  final bool loadingPosts;
  final bool loadingMore;

  /// Set when the posts could not load (the screen shows Try again).
  final String? errorCode;

  FeedState copyWith({
    List<Highlight>? highlights,
    List<Post>? posts,
    PostCategory? Function()? category,
    int? page,
    bool? hasMore,
    bool? loadingPosts,
    bool? loadingMore,
    String? Function()? errorCode,
  }) => FeedState(
    highlights: highlights ?? this.highlights,
    posts: posts ?? this.posts,
    category: category != null ? category() : this.category,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    loadingPosts: loadingPosts ?? this.loadingPosts,
    loadingMore: loadingMore ?? this.loadingMore,
    errorCode: errorCode != null ? errorCode() : this.errorCode,
  );
}

/// The Community feed: highlights, posts of the chosen category, paging,
/// and likes / bookmarks that change on screen at once (rolled back if the
/// call fails). Kept alive so Post details and New post can update it.
class CommunityFeedViewModel extends AsyncNotifier<FeedState> {
  @override
  Future<FeedState> build() async {
    final repo = ref.read(communityRepositoryProvider);
    final (highlights, posts) = await (
      repo.getHighlights(),
      repo.getPosts(),
    ).wait;
    final page = switch (posts) {
      Success(:final value) => value,
      Error(:final failure) => throw failure,
    };
    return FeedState(
      highlights: switch (highlights) {
        Success(:final value) => value,
        Error() => const [],
      },
      posts: page.items,
      page: page.page,
      hasMore: page.hasMore,
    );
  }

  FeedState get _current => state.value ?? const FeedState();

  void _set(FeedState next) => state = AsyncData(next);

  /// Tapping the selected highlight again shows all posts.
  Future<void> selectCategory(PostCategory? category) async {
    final next = _current.category == category ? null : category;
    _set(
      _current.copyWith(
        category: () => next,
        posts: const [],
        loadingPosts: true,
        errorCode: () => null,
      ),
    );
    await _loadFirstPage(next);
  }

  Future<void> _loadFirstPage(PostCategory? category) async {
    final result = await ref
        .read(communityRepositoryProvider)
        .getPosts(category: category);
    if (!ref.mounted || _current.category != category) return;
    switch (result) {
      case Success(:final value):
        _set(
          _current.copyWith(
            posts: value.items,
            page: value.page,
            hasMore: value.hasMore,
            loadingPosts: false,
          ),
        );
      case Error(:final failure):
        _set(
          _current.copyWith(loadingPosts: false, errorCode: () => failure.code),
        );
    }
  }

  /// Pull to refresh and Try again.
  Future<void> refresh() async {
    if (state.value == null) {
      ref.invalidateSelf();
      await future.catchError((_) => const FeedState());
      return;
    }
    final highlights = await ref
        .read(communityRepositoryProvider)
        .getHighlights();
    if (!ref.mounted) return;
    if (highlights case Success(:final value)) {
      _set(_current.copyWith(highlights: value));
    }
    _set(_current.copyWith(errorCode: () => null));
    await _loadFirstPage(_current.category);
  }

  Future<void> loadMore() async {
    final s = _current;
    if (!s.hasMore || s.loadingMore || s.loadingPosts) return;
    _set(s.copyWith(loadingMore: true));
    final result = await ref
        .read(communityRepositoryProvider)
        .getPosts(category: s.category, page: s.page + 1);
    if (!ref.mounted) return;
    switch (result) {
      case Success(:final value):
        _set(
          _current.copyWith(
            posts: [..._current.posts, ...value.items],
            page: value.page,
            hasMore: value.hasMore,
            loadingMore: false,
          ),
        );
      case Error():
        _set(_current.copyWith(loadingMore: false));
    }
  }

  Post? _find(String id) => _current.posts.where((p) => p.id == id).firstOrNull;

  /// Puts an updated post (from Post details) in the list.
  void replace(Post post) {
    if (_find(post.id) == null) return;
    _set(
      _current.copyWith(
        posts: [for (final p in _current.posts) p.id == post.id ? post : p],
      ),
    );
  }

  void remove(String id) => _set(
    _current.copyWith(posts: _current.posts.where((p) => p.id != id).toList()),
  );

  /// A new post goes on top when it fits the chosen category.
  void insertFirst(Post post) {
    final c = _current.category;
    if (c != null && c != post.category) return;
    _set(_current.copyWith(posts: [post, ..._current.posts]));
  }

  /// Returns an error code when the change could not be saved.
  Future<String?> toggleLike(String id) async {
    final post = _find(id);
    if (post == null) return null;
    final liked = !post.isLiked;
    replace(
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
        if (now != null) replace(now.copyWith(likeCount: value));
        return null;
      case Error(:final failure):
        replace(post);
        return failure.code;
    }
  }

  Future<String?> toggleBookmark(String id) async {
    final post = _find(id);
    if (post == null) return null;
    replace(post.copyWith(isBookmarked: !post.isBookmarked));
    final result = await ref
        .read(communityRepositoryProvider)
        .setBookmarked(id, saved: !post.isBookmarked);
    if (!ref.mounted) return null;
    if (result case Error(:final failure)) {
      replace(post);
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
        return null;
      case Error(:final failure):
        return failure.code;
    }
  }
}

final communityFeedProvider =
    AsyncNotifierProvider<CommunityFeedViewModel, FeedState>(
      CommunityFeedViewModel.new,
    );

/// Error code of a failed load, for the error view.
String feedErrorCode(Object error) =>
    error is Failure ? error.code : ErrorCodes.unknown;
