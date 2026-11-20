import '../../../../core/network/upload.dart';
import '../../../../core/pagination/paged.dart';
import '../models/community_dtos.dart';

/// Community endpoints of contract v0.2. The mock and the remote data source
/// both implement this, so the app switches with one flag.
abstract interface class CommunityDataSource {
  /// GET /api/community/stories
  Future<List<HighlightDto>> getHighlights();

  /// GET /api/community/posts?category=&sort=&page=&limit=
  Future<Paged<PostDto>> getPosts({
    String? category,
    String? sort,
    int page = 1,
    int? limit,
  });

  /// GET /api/community/posts/{id}/likes?page=&limit= (v0.3)
  Future<Paged<AuthorDto>> getLikes(String postId, {int page = 1});

  /// GET /api/community/posts/mine?page=&limit=
  Future<Paged<PostDto>> getMyPosts({int page = 1});

  /// GET /api/community/posts/{id}
  Future<PostDto> getPost(String id);

  /// POST /api/community/posts (multipart)
  Future<PostDto> createPost({
    required String caption,
    required String category,
    required List<UploadFile> images,
    String? location,
  });

  /// DELETE /api/community/posts/{id}
  Future<void> deletePost(String id);

  /// POST (like) or DELETE (unlike) /api/community/posts/{id}/like;
  /// returns the new like count.
  Future<int> setLiked(String postId, {required bool liked});

  /// POST or DELETE /api/community/posts/{id}/bookmark
  Future<void> setBookmarked(String postId, {required bool saved});

  /// GET /api/community/posts/{id}/comments?page=&limit=
  Future<Paged<CommentDto>> getComments(String postId, {int page = 1});

  /// POST /api/community/posts/{id}/comments
  Future<CommentDto> addComment(String postId, String text);

  /// DELETE /api/community/comments/{id}
  Future<void> deleteComment(String commentId);
}
