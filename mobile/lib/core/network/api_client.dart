import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_settings.dart';
import '../config/env.dart';
import '../session/session_controller.dart';
import '../storage/app_bootstrap.dart';
import 'api_error_mapper.dart';
import 'auth_interceptor.dart';

/// HTTP client for the Aswani API (contract: `docs/api-contract/`).
///
/// Every remote data source uses this one client: base URL, JSON, timeouts
/// and the Bearer token with automatic refresh. Calls go through [apiCall],
/// which turns errors into the contract's `AppException`.
final apiClientProvider = Provider<Dio>((ref) {
  BaseOptions options() => BaseOptions(
    baseUrl: Env.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 20),
    contentType: Headers.jsonContentType,
    responseType: ResponseType.json,
  );

  final client = Dio(options());
  client.interceptors.add(
    AuthInterceptor(
      tokens: ref.watch(secureStoreProvider),
      refreshClient: Dio(options()),
      retryClient: Dio(options()),
      language: () => ref.read(localeProvider).languageCode,
      onSessionExpired: () => ref.read(sessionProvider.notifier).signOut(),
    ),
  );
  ref.onDispose(client.close);
  return client;
});

/// Runs a request and throws the contract's AppException on any failure.
Future<T> apiCall<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (e) {
    throw mapDioError(e);
  }
}
