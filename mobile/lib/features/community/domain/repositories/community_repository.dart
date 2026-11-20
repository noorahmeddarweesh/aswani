import '../../../../core/network/upload.dart';
import '../../../../core/pagination/paged.dart';
import '../../../../core/result/result.dart';
import '../entities/post.dart';

/// Community data, whatever the source (mock or API).
abstract interface class CommunityRepository {
  Future<Result<List<Highlight>>> getHighlights();

  Future<Result<Paged<Post>>> getPosts({PostCategory? category, int page = 1});

  Future<Result<Paged<Post>>> getMyPosts({int page = 1});

  Future<Result<Post>> getPost(String id);

  Future<Result<Post>> createPost({
    required String caption,
    required PostCategory category,
    required List<UploadFile> images,
    String? location,
  });

  Future<Result<void>> deletePost(String id);

  /// Returns the new like count.
  Future<Result<int>> setLiked(String postId, {required bool liked});

  Future<Result<void>> setBookmarked(String postId, {required bool saved});

  Future<Result<Paged<Comment>>> getComments(String postId, {int page = 1});

  Future<Result<Comment>> addComment(String postId, String text);

  Future<Result<void>> deleteComment(String commentId);
}
