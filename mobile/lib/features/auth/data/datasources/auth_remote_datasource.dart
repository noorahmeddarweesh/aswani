import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/key_value_store.dart';
import '../models/auth_response_dto.dart';
import '../models/user_dto.dart';
import 'auth_datasource.dart';

/// Auth endpoints of the real API (contract: Auth section).
class AuthRemoteDataSource implements AuthDataSource {
  AuthRemoteDataSource(this._client, this._tokens);

  final Dio _client;

  /// Secure storage, read for the refresh token on logout.
  final KeyValueStore _tokens;

  @override
  Future<AuthResponseDto> login({
    required String identifier,
    required String password,
  }) => apiCall(() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'identifier': identifier, 'password': password},
    );
    return AuthResponseDto.fromJson(response.data!);
  });

  @override
  Future<AuthResponseDto> register({
    required String fullName,
    required String identifier,
    required String password,
  }) => apiCall(() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'full_name': fullName,
        'identifier': identifier,
        'password': password,
      },
    );
    return AuthResponseDto.fromJson(response.data!);
  });

  @override
  Future<void> forgotPassword({required String identifier}) => apiCall(
    () => _client.post<void>(
      '/auth/forgot-password',
      data: {'identifier': identifier},
    ),
  );

  @override
  Future<void> resetPassword({
    required String identifier,
    required String code,
    required String newPassword,
  }) => apiCall(
    () => _client.post<void>(
      '/auth/reset-password',
      data: {
        'identifier': identifier,
        'code': code,
        'new_password': newPassword,
      },
    ),
  );

  @override
  Future<void> logout() => apiCall(() async {
    final refreshToken = await _tokens.read(StorageKeys.refreshToken);
    if (refreshToken == null) return;
    await _client.post<void>(
      '/auth/logout',
      data: {'refresh_token': refreshToken},
    );
  });

  @override
  Future<UserDto> me() => apiCall(() async {
    final response = await _client.get<Map<String, dynamic>>('/users/me');
    return UserDto.fromJson(response.data!['data'] as Map<String, dynamic>);
  });
}
