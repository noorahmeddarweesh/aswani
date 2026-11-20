import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/upload.dart';
import '../../../../core/pagination/paged.dart';
import '../models/community_dtos.dart';
import 'community_datasource.dart';

/// Community endpoints of the real API (contract v0.2, Community).
class CommunityRemoteDataSource implements CommunityDataSource {
  CommunityRemoteDataSource(this._client);

  final Dio _client;

  static const _base = '/community';

  Map<String, dynamic> _data(Response<Map<String, dynamic>> r) =>
      r.data!['data'] as Map<String, dynamic>;

  @override
  Future<List<HighlightDto>> getHighlights() => apiCall(() async {
    final r = await _client.get<Map<String, dynamic>>('$_base/stories');
    return [
      for (final e in r.data!['data'] as List<dynamic>)
        HighlightDto.fromJson(e as Map<String, dynamic>),
    ];
  });

  @override
  Future<Paged<PostDto>> getPosts({String? category, int page = 1}) =>
      apiCall(() async {
        final r = await _client.get<Map<String, dynamic>>(
          '$_base/posts',
          queryParameters: {
            'category': ?category,
            'page': page,
            'limit': kPageSize,
          },
        );
        return Paged.fromJson(r.data!, PostDto.fromJson);
      });

  @override
  Future<Paged<PostDto>> getMyPosts({int page = 1}) => apiCall(() async {
    final r = await _client.get<Map<String, dynamic>>(
      '$_base/posts/mine',
      queryParameters: {'page': page, 'limit': kPageSize},
    );
    return Paged.fromJson(r.data!, PostDto.fromJson);
  });

  @override
  Future<PostDto> getPost(String id) => apiCall(() async {
    final r = await _client.get<Map<String, dynamic>>('$_base/posts/$id');
    return PostDto.fromJson(_data(r));
  });

  @override
  Future<PostDto> createPost({
    required String caption,
    required String category,
    required List<UploadFile> images,
    String? location,
  }) => apiCall(() async {
    final r = await _client.post<Map<String, dynamic>>(
      '$_base/posts',
      data: buildFormData(
        fields: {
          'caption': caption,
          'location': location,
          'category': category,
        },
        files: images,
      ),
    );
    return PostDto.fromJson(_data(r));
  });

  @override
  Future<void> deletePost(String id) =>
      apiCall(() => _client.delete<void>('$_base/posts/$id'));

  @override
  Future<int> setLiked(String postId, {required bool liked}) =>
      apiCall(() async {
        final path = '$_base/posts/$postId/like';
        final r = liked
            ? await _client.post<Map<String, dynamic>>(path)
            : await _client.delete<Map<String, dynamic>>(path);
        return _data(r)['like_count'] as int;
      });

  @override
  Future<void> setBookmarked(String postId, {required bool saved}) => apiCall(
    () async {
      final path = '$_base/posts/$postId/bookmark';
      saved ? await _client.post<void>(path) : await _client.delete<void>(path);
    },
  );

  @override
  Future<Paged<CommentDto>> getComments(String postId, {int page = 1}) =>
      apiCall(() async {
        final r = await _client.get<Map<String, dynamic>>(
          '$_base/posts/$postId/comments',
          queryParameters: {'page': page, 'limit': kPageSize},
        );
        return Paged.fromJson(r.data!, CommentDto.fromJson);
      });

  @override
  Future<CommentDto> addComment(String postId, String text) =>
      apiCall(() async {
        final r = await _client.post<Map<String, dynamic>>(
          '$_base/posts/$postId/comments',
          data: {'text': text},
        );
        return CommentDto.fromJson(_data(r));
      });

  @override
  Future<void> deleteComment(String commentId) =>
      apiCall(() => _client.delete<void>('$_base/comments/$commentId'));
}
