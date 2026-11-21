import 'dart:typed_data';

import 'package:aswani/core/network/auth_interceptor.dart';
import 'package:aswani/core/network/upload.dart';
import 'package:aswani/core/storage/key_value_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_api.dart';

UploadFile _photo(String name, [int size = 10]) =>
    UploadFile(name: name, bytes: Uint8List(size), path: '/tmp/$name');

void main() {
  test(
    'form fields: snake_case names, lists repeated, files under one name',
    () {
      final form = buildFormData(
        fields: {
          'caption': 'Sunset',
          'location': null,
          'languages': ['ar', 'en'],
        },
        files: [_photo('a.jpg'), _photo('b.png')],
      );
      expect(form.fields.map((e) => '${e.key}=${e.value}'), [
        'caption=Sunset',
        'languages=ar',
        'languages=en',
      ]);
      expect(form.files.map((e) => e.key), ['images', 'images']);
      expect(form.files.last.value.contentType.toString(), 'image/png');
    },
  );

  test('photos over 5 MB or of another type are refused', () {
    expect(checkUpload(_photo('a.JPG')), isNull);
    expect(checkUpload(_photo('a.webp')), isNull);
    expect(checkUpload(_photo('a.gif')), 'UNSUPPORTED_FILE_TYPE');
    expect(
      checkUpload(_photo('big.jpg', UploadRules.maxBytes + 1)),
      'FILE_TOO_LARGE',
    );
  });

  test('a multipart request is sent again after a token refresh', () async {
    final tokens = MemoryKeyValueStore({
      StorageKeys.accessToken: 'old',
      StorageKeys.refreshToken: 'r',
    });
    final api = FakeApi((request) {
      if (request.path == '/auth/refresh') {
        return reply(200, {
          'data': {'access_token': 'new', 'refresh_token': 'r2'},
        });
      }
      return request.headers['Authorization'] == 'Bearer new'
          ? reply(201, {'data': 'ok'})
          : reply(401, apiError('UNAUTHORIZED'));
    });
    final client = api.client()
      ..interceptors.add(
        AuthInterceptor(
          tokens: tokens,
          refreshClient: api.client(),
          retryClient: api.client(),
          language: () => 'en',
          onSessionExpired: () {},
        ),
      );

    final response = await client.post<Map<String, dynamic>>(
      '/community/posts',
      data: buildFormData(fields: {'caption': 'x'}, files: [_photo('a.jpg')]),
    );

    expect(response.statusCode, 201);
    final sent = api.requests.where((r) => r.path == '/community/posts');
    expect(sent, hasLength(2));
    expect(sent.last.data, isA<FormData>());
    expect(identical(sent.first.data, sent.last.data), isFalse);
  });
}
