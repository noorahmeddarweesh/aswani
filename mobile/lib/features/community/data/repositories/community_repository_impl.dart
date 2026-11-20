import '../../../../core/network/upload.dart';
import '../../../../core/pagination/paged.dart';
import '../../../../core/result/guard.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/community_repository.dart';
import '../datasources/community_datasource.dart';
import '../mappers/community_mapper.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  CommunityRepositoryImpl(this._source);

  final CommunityDataSource _source;

  @override
  Future<Result<List<Highlight>>> getHighlights() => guard(
    () async => [for (final h in await _source.getHighlights()) h.toEntity()],
  );

  @override
  Future<Result<Paged<Post>>> getPosts({
    PostCategory? category,
    int page = 1,
  }) => guard(
    () async => (await _source.getPosts(
      category: category?.wire,
      page: page,
    )).map((p) => p.toEntity()),
  );

  @override
  Future<Result<Paged<Post>>> getMyPosts({int page = 1}) => guard(
    () async => (await _source.getMyPosts(page: page)).map((p) => p.toEntity()),
  );

  @override
  Future<Result<Post>> getPost(String id) =>
      guard(() async => (await _source.getPost(id)).toEntity());

  @override
  Future<Result<Post>> createPost({
    required String caption,
    required PostCategory category,
    required List<UploadFile> images,
    String? location,
  }) => guard(
    () async => (await _source.createPost(
      caption: caption,
      category: category.wire,
      images: images,
      location: location,
    )).toEntity(),
  );

  @override
  Future<Result<void>> deletePost(String id) =>
      guard(() => _source.deletePost(id));

  @override
  Future<Result<int>> setLiked(String postId, {required bool liked}) =>
      guard(() => _source.setLiked(postId, liked: liked));

  @override
  Future<Result<void>> setBookmarked(String postId, {required bool saved}) =>
      guard(() => _source.setBookmarked(postId, saved: saved));

  @override
  Future<Result<Paged<Comment>>> getComments(String postId, {int page = 1}) =>
      guard(
        () async => (await _source.getComments(
          postId,
          page: page,
        )).map((c) => c.toEntity()),
      );

  @override
  Future<Result<Comment>> addComment(String postId, String text) =>
      guard(() async => (await _source.addComment(postId, text)).toEntity());

  @override
  Future<Result<void>> deleteComment(String commentId) =>
      guard(() => _source.deleteComment(commentId));
}
