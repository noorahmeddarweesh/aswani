import 'user_dto.dart';

/// Response of login and register:
/// `{ "data": { "user": {...}, "access_token", "refresh_token" } }`.
class AuthResponseDto {
  const AuthResponseDto({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return AuthResponseDto(
      user: UserDto.fromJson(data['user'] as Map<String, dynamic>),
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
    );
  }

  final UserDto user;
  final String accessToken;
  final String refreshToken;
}
