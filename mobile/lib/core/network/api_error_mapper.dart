import 'package:dio/dio.dart';

import '../errors/app_exception.dart';
import '../errors/failure.dart';

/// Turns any Dio error into the contract's [AppException], so repositories
/// and screens see the same error codes for the mock and the real API.
///
/// - Server errors keep the contract body:
///   `{ "error": { "code", "message", "details" } }`.
/// - No network -> `NO_CONNECTION`, too slow -> `TIMEOUT` (made by the app).
AppException mapDioError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return AppException(code: ErrorCodes.timeout, message: '${error.type}');
    case DioExceptionType.connectionError:
      return AppException(
        code: ErrorCodes.noConnection,
        message: '${error.message}',
      );
    case DioExceptionType.badResponse:
      return _fromResponse(error.response);
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      final inner = error.error;
      if (inner is AppException) return inner;
      return AppException(
        code: ErrorCodes.noConnection,
        message: '${error.message ?? inner}',
      );
  }
}

AppException _fromResponse(Response<dynamic>? response) {
  final status = response?.statusCode;
  final body = response?.data;
  if (body is Map && body['error'] is Map) {
    final error = body['error'] as Map;
    final details = error['details'];
    return AppException(
      code: '${error['code'] ?? ErrorCodes.unknown}',
      message: '${error['message'] ?? ''}',
      details: details is Map
          ? {for (final e in details.entries) '${e.key}': '${e.value}'}
          : const {},
      statusCode: status,
    );
  }
  // A body outside the contract (proxy page, crash): fall back on the status.
  final code = switch (status) {
    401 => ErrorCodes.unauthorized,
    final s? when s >= 500 => ErrorCodes.serverError,
    _ => ErrorCodes.unknown,
  };
  return AppException(code: code, statusCode: status);
}
