import 'package:dio/dio.dart';

import '../storage/key_value_store.dart';

/// Adds `Authorization: Bearer <access_token>` and the app language to every
/// request. When a request comes back `401 UNAUTHORIZED`, refreshes the
/// tokens once (`POST /auth/refresh`) and retries it; if the refresh fails,
/// clears the tokens and calls [onSessionExpired] (the app signs out).
///
/// A [QueuedInterceptor] handles one error at a time, so several requests
/// failing together trigger a single refresh.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this.tokens,
    required this.refreshClient,
    required this.language,
    required this.onSessionExpired,
    required this.retryClient,
  });

  final KeyValueStore tokens;

  /// Plain client (no interceptors) used for the refresh call itself.
  final Dio refreshClient;

  /// Client used to repeat the original request after a refresh.
  final Dio retryClient;

  /// Current app language code (`ar` or `en`).
  final String Function() language;

  final void Function() onSessionExpired;

  /// Endpoints that never carry a token (contract: shared conventions).
  static const publicPaths = {
    '/auth/register',
    '/auth/login',
    '/auth/refresh',
    '/auth/forgot-password',
    '/auth/reset-password',
  };

  static const _retried = 'auth_retried';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['Accept-Language'] = language();
    if (!publicPaths.contains(options.path)) {
      final token = await tokens.read(StorageKeys.accessToken);
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final unauthorized = err.response?.statusCode == 401;
    if (!unauthorized ||
        publicPaths.contains(request.path) ||
        request.extra[_retried] == true) {
      return handler.next(err);
    }

    // Another request may have refreshed already while this one waited.
    final sent = request.headers['Authorization'];
    final current = await tokens.read(StorageKeys.accessToken);
    final alreadyRefreshed = current != null && sent != 'Bearer $current';

    if (!alreadyRefreshed && !await _refresh()) {
      await _expire();
      return handler.next(err);
    }

    try {
      final token = await tokens.read(StorageKeys.accessToken);
      final retry = request.copyWith(
        headers: {...request.headers, 'Authorization': 'Bearer $token'},
        extra: {...request.extra, _retried: true},
      );
      handler.resolve(await retryClient.fetch<dynamic>(retry));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<bool> _refresh() async {
    final refreshToken = await tokens.read(StorageKeys.refreshToken);
    if (refreshToken == null) return false;
    try {
      final response = await refreshClient.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final data = response.data?['data'] as Map<String, dynamic>?;
      final access = data?['access_token'] as String?;
      final refresh = data?['refresh_token'] as String?;
      if (access == null) return false;
      await tokens.write(StorageKeys.accessToken, access);
      if (refresh != null) {
        await tokens.write(StorageKeys.refreshToken, refresh);
      }
      return true;
    } on DioException {
      return false;
    }
  }

  Future<void> _expire() async {
    await tokens.delete(StorageKeys.accessToken);
    await tokens.delete(StorageKeys.refreshToken);
    onSessionExpired();
  }
}
