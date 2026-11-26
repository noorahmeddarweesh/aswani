import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Answers Dio requests in tests without a network, and records them, so a
/// test can check the method, path and body against the API contract.
class FakeApi implements HttpClientAdapter {
  FakeApi(this.handler);

  /// Returns the response for a request: `reply(200, {...})`.
  ResponseBody Function(RequestOptions request) handler;

  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}

  /// A Dio client on a fake base URL that uses this adapter.
  Dio client() =>
      Dio(BaseOptions(baseUrl: 'https://api.test/api'))
        ..httpClientAdapter = this;
}

/// A JSON response (or an empty one when [body] is null).
ResponseBody reply(int status, [Object? body]) => ResponseBody.fromString(
  body == null ? '' : jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

/// The contract's error body.
Map<String, dynamic> apiError(String code, [Map<String, String>? details]) => {
  'error': {'code': code, 'message': 'test', 'details': ?details},
};
