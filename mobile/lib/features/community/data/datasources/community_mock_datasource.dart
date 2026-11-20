import '../../../../core/assets/app_images.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/upload.dart';
import '../../../../core/pagination/paged.dart';
import '../models/community_dtos.dart';
import 'community_datasource.dart';

/// In-memory community that answers exactly like contract v0.2. Posts made
/// here last until the app closes.
class CommunityMockDataSource implements CommunityDataSource {
  CommunityMockDataSource({
    this.delay = const Duration(milliseconds: 500),
    this.pageSize = kPageSize,
    AuthorDto Function()? me,
    DateTime Function()? now,
  }) : _me = me ?? (() => _laila),
       _now = now ?? DateTime.now {
    _seed();
  }

  final Duration delay;
  final int pageSize;
  final AuthorDto Function() _me;
  final DateTime Function() _now;

  final List<PostDto> _posts = [];
  final Map<String, List<CommentDto>> _comments = {};
  final Set<String> _liked = {'p_mariam'};
  final Set<String> _saved = {};
  int _nextId = 1;

  static const _laila = AuthorDto(
    id: 'u_1',
    fullName: 'Laila Hassan',
    avatar: AppImages.avatarLaila,
  );

  static const List<HighlightDto> _highlights = [
    HighlightDto(
      id: 'h_nubia',
      titleEn: 'Nubia',
      titleAr: 'النوبة',
      coverImage: AppImages.onboardingNubian,
      category: 'nubian',
    ),
    HighlightDto(
      id: 'h_nile',
      titleEn: 'On the Nile',
      titleAr: 'على النيل',
      coverImage: AppImages.homeHero,
      category: 'nile',
    ),
    HighlightDto(
      id: 'h_local',
      titleEn: 'Local life',
      titleAr: 'حياة محلية',
      coverImage: AppImages.onboardingMarket,
      category: 'local_experience',
    ),
  ];

  String _ago(Duration d) => _now().toUtc().subtract(d).toIso8601String();

  void _seed() {
    const mariam = AuthorDto(id: 'u_2', fullName: 'Mariam Ahmed');
    const omar = AuthorDto(id: 'u_3', fullName: 'عمر علي');
    const maya = AuthorDto(id: 'u_4', fullName: 'Maya');
    const youssef = AuthorDto(id: 'u_5', fullName: 'Youssef El Nuby');

    _posts.addAll([
      PostDto(
        id: 'p_sunset',
        author: _laila,
        images: const [AppImages.homeHero2, AppImages.homeHero],
        caption:
            'A quiet sunset and a sail passing through the story. This is '
            'the Aswan I love. #NileMoments',
        location: 'Aswan Corniche',
        category: 'nile',
        likeCount: 124,
        commentCount: 3,
        isLiked: false,
        isBookmarked: false,
        createdAt: _ago(const Duration(hours: 2)),
      ),
      PostDto(
        id: 'p_mariam',
        author: mariam,
        images: const [AppImages.nubianVillage, AppImages.homeStory],
        caption:
            'Every door in Gharb Soheil tells you who lives behind it. '
            '#NubianColors',
        location: 'Gharb Soheil',
        category: 'nubian',
        likeCount: 87,
        commentCount: 1,
        isLiked: true,
        isBookmarked: false,
        createdAt: _ago(const Duration(hours: 5)),
      ),
      PostDto(
        id: 'p_souq',
        author: omar,
        images: const [AppImages.onboardingMarket],
        caption: 'رائحة الكركديه والتوابل في سوق أسوان لا تُنسى. #سوق_أسوان',
        location: 'سوق أسوان',
        category: 'food',
        likeCount: 41,
        commentCount: 0,
        isLiked: false,
        isBookmarked: false,
        createdAt: _ago(const Duration(days: 1)),
      ),
      PostDto(
        id: 'p_philae',
        author: youssef,
        images: const [AppImages.philaeTemple],
        caption:
            'Morning boat to Philae before the crowds. The light on the '
            'columns is worth the early start.',
        location: 'Philae Temple',
        category: 'local_experience',
        likeCount: 63,
        commentCount: 0,
        isLiked: false,
        isBookmarked: false,
        createdAt: _ago(const Duration(days: 2)),
      ),
    ]);

    _comments['p_sunset'] = [
      CommentDto(
        id: 'c_1',
        author: omar,
        text: 'مشهد جميل جدًا، خصوصًا قبل الغروب.',
        createdAt: _ago(const Duration(minutes: 35)),
      ),
      CommentDto(
        id: 'c_2',
        author: maya,
        text: 'Adding this walk to my list!',
        createdAt: _ago(const Duration(hours: 1)),
      ),
      CommentDto(
        id: 'c_3',
        author: mariam,
        text: 'The felucca at that hour is pure Aswan.',
        createdAt: _ago(const Duration(minutes: 50)),
      ),
    ]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _comments['p_mariam'] = [
      CommentDto(
        id: 'c_4',
        author: _laila,
        text: 'I want to visit this week!',
        createdAt: _ago(const Duration(hours: 3)),
      ),
    ];
  }

  Future<void> _wait() => Future<void>.delayed(delay);

  PostDto _view(PostDto p) => PostDto(
    id: p.id,
    author: p.author,
    images: p.images,
    caption: p.caption,
    location: p.location,
    category: p.category,
    likeCount: p.likeCount,
    commentCount: _comments[p.id]?.length ?? 0,
    isLiked: _liked.contains(p.id),
    isBookmarked: _saved.contains(p.id),
    createdAt: p.createdAt,
  );

  PostDto _find(String id) => _posts.firstWhere(
    (p) => p.id == id,
    orElse: () => throw const AppException(
      code: ErrorCodes.postNotFound,
      statusCode: 404,
    ),
  );

  Paged<T> _page<T>(List<T> all, int page) {
    final totalPages = all.isEmpty ? 1 : (all.length / pageSize).ceil();
    final start = (page - 1) * pageSize;
    return Paged(
      items: all.skip(start).take(pageSize).toList(),
      page: page,
      totalPages: totalPages,
      total: all.length,
    );
  }

  @override
  Future<List<HighlightDto>> getHighlights() async {
    await _wait();
    return _highlights;
  }

  @override
  Future<Paged<PostDto>> getPosts({String? category, int page = 1}) async {
    await _wait();
    final all = [
      for (final p in _posts)
        if (category == null || p.category == category) _view(p),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return _page(all, page);
  }

  @override
  Future<Paged<PostDto>> getMyPosts({int page = 1}) async {
    await _wait();
    final me = _me().id;
    final all = [
      for (final p in _posts)
        if (p.author.id == me) _view(p),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return _page(all, page);
  }

  @override
  Future<PostDto> getPost(String id) async {
    await _wait();
    return _view(_find(id));
  }

  @override
  Future<PostDto> createPost({
    required String caption,
    required String category,
    required List<UploadFile> images,
    String? location,
  }) async {
    await _wait();
    if (images.length > UploadRules.maxPhotos) {
      throw const AppException(code: ErrorCodes.tooManyPhotos, statusCode: 422);
    }
    if (images.isEmpty || caption.trim().isEmpty) {
      throw AppException(
        code: ErrorCodes.validation,
        statusCode: 422,
        details: {
          if (images.isEmpty) 'images': ErrorCodes.validation,
          if (caption.trim().isEmpty) 'caption': ErrorCodes.validation,
        },
      );
    }
    final post = PostDto(
      id: 'p_new_${_nextId++}',
      author: _me(),
      // The mock keeps the picked files; the API returns full URLs.
      images: [for (final f in images) f.path],
      caption: caption.trim(),
      location: location,
      category: category,
      likeCount: 0,
      commentCount: 0,
      isLiked: false,
      isBookmarked: false,
      createdAt: _now().toUtc().toIso8601String(),
    );
    _posts.add(post);
    return _view(post);
  }

  @override
  Future<void> deletePost(String id) async {
    await _wait();
    final post = _find(id);
    if (post.author.id != _me().id) {
      throw const AppException(code: ErrorCodes.forbidden, statusCode: 403);
    }
    _posts.remove(post);
    _comments.remove(id);
  }

  @override
  Future<int> setLiked(String postId, {required bool liked}) async {
    await _wait();
    final post = _find(postId);
    final was = _liked.contains(postId);
    if (liked == was) return post.likeCount;
    liked ? _liked.add(postId) : _liked.remove(postId);
    final count = post.likeCount + (liked ? 1 : -1);
    _posts[_posts.indexOf(post)] = PostDto(
      id: post.id,
      author: post.author,
      images: post.images,
      caption: post.caption,
      location: post.location,
      category: post.category,
      likeCount: count,
      commentCount: post.commentCount,
      isLiked: liked,
      isBookmarked: post.isBookmarked,
      createdAt: post.createdAt,
    );
    return count;
  }

  @override
  Future<void> setBookmarked(String postId, {required bool saved}) async {
    await _wait();
    _find(postId);
    saved ? _saved.add(postId) : _saved.remove(postId);
  }

  @override
  Future<Paged<CommentDto>> getComments(String postId, {int page = 1}) async {
    await _wait();
    _find(postId);
    return _page(_comments[postId] ?? const [], page);
  }

  @override
  Future<CommentDto> addComment(String postId, String text) async {
    await _wait();
    _find(postId);
    if (text.trim().isEmpty) {
      throw const AppException(
        code: ErrorCodes.validation,
        statusCode: 422,
        details: {'text': ErrorCodes.validation},
      );
    }
    final comment = CommentDto(
      id: 'c_new_${_nextId++}',
      author: _me(),
      text: text.trim(),
      createdAt: _now().toUtc().toIso8601String(),
    );
    (_comments[postId] ??= []).add(comment);
    return comment;
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await _wait();
    for (final list in _comments.values) {
      final i = list.indexWhere((c) => c.id == commentId);
      if (i < 0) continue;
      if (list[i].author.id != _me().id) {
        throw const AppException(code: ErrorCodes.forbidden, statusCode: 403);
      }
      list.removeAt(i);
      return;
    }
    throw const AppException(code: ErrorCodes.commentNotFound, statusCode: 404);
  }

  /// Saved posts, for "My saved content" in the profile.
  int get savedCount => _saved.length;
}
