import '../models/auth_response_dto.dart';

/// Contract of the auth endpoints. Implemented by the mock now and by the
/// remote (dio) data source when the backend is ready. Throws AppException.
abstract interface class AuthDataSource {
  /// POST /api/auth/login
  Future<AuthResponseDto> login({
    required String identifier,
    required String password,
  });

  /// POST /api/auth/register
  Future<AuthResponseDto> register({
    required String fullName,
    required String identifier,
    required String password,
  });

  /// POST /api/auth/forgot-password
  Future<void> forgotPassword({required String identifier});

  /// POST /api/auth/reset-password
  Future<void> resetPassword({
    required String identifier,
    required String code,
    required String newPassword,
  });

  /// POST /api/auth/logout
  Future<void> logout();
}
