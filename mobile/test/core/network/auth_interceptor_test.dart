import 'package:aswani/core/errors/app_exception.dart';
import 'package:aswani/core/network/api_client.dart';
import 'package:aswani/core/network/api_error_mapper.dart';
import 'package:aswani/core/network/auth_interceptor.dart';
import 'package:aswani/core/storage/key_value_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_api.dart';

void main() {
  late FakeApi api;
  late MemoryKeyValueStore tokens;
  late Dio client;
  late int expired;

  setUp(() {
    expired = 0;
    tokens = MemoryKeyValueStore({
      StorageKeys.accessToken: 'old',
      StorageKeys.refreshToken: 'r-old',
    });
    api = FakeApi((_) => reply(200, {'data': 'ok'}));
    client = api.client()
      ..interceptors.add(
        AuthInterceptor(
          tokens: tokens,
          refreshClient: api.client(),
          retryClient: api.client(),
          language: () => 'ar',
          onSessionExpired: () => expired++,
        ),
      );
  });

  test('adds the Bearer token and the language', () async {
    await client.get<void>('/users/me');
    final headers = api.requests.single.headers;
    expect(headers['Authorization'], 'Bearer old');
    expect(headers['Accept-Language'], 'ar');
  });

  test('public endpoints are sent without a token', () async {
    await client.post<void>('/auth/login', data: const <String, String>{});
    expect(api.requests.single.headers.containsKey('Authorization'), isFalse);
  });

  test('401 refreshes once, saves new tokens and retries', () async {
    api.handler = (request) {
      if (request.path == '/auth/refresh') {
        return reply(200, {
          'data': {'access_token': 'new', 'refresh_token': 'r-new'},
        });
      }
      return request.headers['Authorization'] == 'Bearer new'
          ? reply(200, {'data': 'ok'})
          : reply(401, apiError('UNAUTHORIZED'));
    };

    final response = await client.get<Map<String, dynamic>>('/places');

    expect(response.data, {'data': 'ok'});
    expect(api.requests.map((r) => r.path), [
      '/places',
      '/auth/refresh',
      '/places',
    ]);
    expect(api.requests[1].data, {'refresh_token': 'r-old'});
    expect(await tokens.read(StorageKeys.accessToken), 'new');
    expect(await tokens.read(StorageKeys.refreshToken), 'r-new');
    expect(expired, 0);
  });

  test('a failed refresh clears the tokens and signs out', () async {
    api.handler = (_) => reply(401, apiError('UNAUTHORIZED'));

    await expectLater(
      apiCall(() => client.get<void>('/places')),
      throwsA(
        isA<AppException>().having((e) => e.code, 'code', 'UNAUTHORIZED'),
      ),
    );
    expect(await tokens.read(StorageKeys.accessToken), isNull);
    expect(await tokens.read(StorageKeys.refreshToken), isNull);
    expect(expired, 1);
  });

  group('error mapping', () {
    final request = RequestOptions(path: '/places');

    test('no network and timeouts are produced by the app', () {
      expect(
        mapDioError(
          DioException.connectionError(requestOptions: request, reason: 'x'),
        ).code,
        'NO_CONNECTION',
      );
      expect(
        mapDioError(
          DioException.receiveTimeout(
            timeout: Duration.zero,
            requestOptions: request,
          ),
        ).code,
        'TIMEOUT',
      );
    });

    test('a 5xx without the contract body is SERVER_ERROR', () {
      final error = DioException.badResponse(
        statusCode: 502,
        requestOptions: request,
        response: Response(
          requestOptions: request,
          statusCode: 502,
          data: '<html>Bad gateway</html>',
        ),
      );
      expect(mapDioError(error).code, 'SERVER_ERROR');
    });
  });
}
