import 'dart:typed_data';

import 'package:aswani/core/network/upload.dart';
import 'package:aswani/core/result/result.dart';
import 'package:aswani/features/community/data/datasources/community_mock_datasource.dart';
import 'package:aswani/features/community/data/datasources/community_remote_datasource.dart';
import 'package:aswani/features/community/data/repositories/community_repository_impl.dart';
import 'package:aswani/features/community/domain/entities/post.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_api.dart';

T ok<T>(Result<T> r) => (r as Success<T>).value;
String code(Result<Object?> r) => (r as Error).failure.code;

final _photo = UploadFile(name: 'a.jpg', bytes: Uint8List(4), path: '/a.jpg');

const _postJson = {
  'id': 'p1',
  'author': {'id': 'u_1', 'full_name': 'Laila Hassan', 'avatar': null},
  'images': ['https://api.test/p1.jpg'],
  'caption': 'Sunset',
  'location': null,
  'category': 'nile',
  'like_count': 3,
  'comment_count': 1,
  'is_liked': false,
  'is_bookmarked': true,
  'created_at': '2026-11-20T10:00:00Z',
};

void main() {
  group('mock repository', () {
    late CommunityRepositoryImpl repo;
    setUp(
      () => repo = CommunityRepositoryImpl(
        CommunityMockDataSource(delay: Duration.zero, pageSize: 2),
      ),
    );

    test('posts are newest first, paged, and filtered by category', () async {
      final first = ok(await repo.getPosts());
      expect(first.items.map((p) => p.id), ['p_sunset', 'p_mariam']);
      expect(first.hasMore, isTrue);
      final second = ok(await repo.getPosts(page: 2));
      expect(second.items.map((p) => p.id), ['p_souq', 'p_philae']);
      expect(second.hasMore, isFalse);
      final nubian = ok(await repo.getPosts(category: PostCategory.nubian));
      expect(nubian.items.single.id, 'p_mariam');
    });

    test('like, bookmark, comment and delete follow the contract', () async {
      expect(ok(await repo.setLiked('p_sunset', liked: true)), 125);
      expect(ok(await repo.setLiked('p_sunset', liked: false)), 124);
      ok(await repo.setBookmarked('p_sunset', saved: true));
      expect(ok(await repo.getPost('p_sunset')).isBookmarked, isTrue);

      final comment = ok(await repo.addComment('p_sunset', ' Lovely '));
      expect(comment.text, 'Lovely');
      expect(ok(await repo.getPost('p_sunset')).commentCount, 4);
      expect(code(await repo.addComment('p_sunset', '  ')), 'VALIDATION_ERROR');
      ok(await repo.deleteComment(comment.id));
      expect(code(await repo.deleteComment('c_1')), 'FORBIDDEN');

      expect(code(await repo.deletePost('p_mariam')), 'FORBIDDEN');
      ok(await repo.deletePost('p_sunset'));
      expect(code(await repo.getPost('p_sunset')), 'POST_NOT_FOUND');
    });

    test('a new post needs a photo and a caption, at most 6 photos', () async {
      final post = ok(
        await repo.createPost(
          caption: 'New',
          category: PostCategory.food,
          images: [_photo],
          location: 'Souq',
        ),
      );
      expect(post.author.id, 'u_1');
      expect(ok(await repo.getMyPosts()).items.first.id, post.id);
      expect(
        code(
          await repo.createPost(
            caption: 'x',
            category: PostCategory.food,
            images: List.filled(7, _photo),
          ),
        ),
        'TOO_MANY_PHOTOS',
      );
      expect(
        code(
          await repo.createPost(
            caption: '',
            category: PostCategory.food,
            images: const [],
          ),
        ),
        'VALIDATION_ERROR',
      );
    });
  });

  group('remote data source', () {
    test('paths, query, body and parsing match contract v0.2', () async {
      final api = FakeApi(
        (r) => switch ((r.method, r.path)) {
          ('GET', '/community/posts') => reply(200, {
            'data': [_postJson],
            'meta': {'page': 1, 'limit': 20, 'total': 1, 'total_pages': 1},
          }),
          ('POST', '/community/posts') => reply(201, {'data': _postJson}),
          ('POST', '/community/posts/p1/like') => reply(200, {
            'data': {'like_count': 4, 'is_liked': true},
          }),
          ('POST', '/community/posts/p1/comments') => reply(201, {
            'data': {
              'id': 'c1',
              'author': _postJson['author'],
              'text': 'Hi',
              'created_at': '2026-11-20T10:00:00Z',
            },
          }),
          _ => reply(204),
        },
      );
      final remote = CommunityRemoteDataSource(api.client());

      final page = await remote.getPosts(category: 'nile');
      expect(api.requests.last.queryParameters, {
        'category': 'nile',
        'page': 1,
        'limit': 20,
      });
      expect(page.items.single.isBookmarked, isTrue);

      await remote.createPost(
        caption: 'Sunset',
        category: 'nile',
        images: [_photo],
      );
      expect(api.requests.last.data.toString(), contains('FormData'));

      expect(await remote.setLiked('p1', liked: true), 4);
      await remote.setBookmarked('p1', saved: false);
      expect(api.requests.last.method, 'DELETE');
      expect(api.requests.last.path, '/community/posts/p1/bookmark');

      await remote.addComment('p1', 'Hi');
      expect(api.requests.last.data, {'text': 'Hi'});
      await remote.deleteComment('c1');
      expect(api.requests.last.path, '/community/comments/c1');
      await remote.deletePost('p1');
      expect(api.requests.last.path, '/community/posts/p1');
    });
  });
}
