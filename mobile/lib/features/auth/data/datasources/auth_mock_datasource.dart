import '../../../../core/assets/app_images.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../models/auth_response_dto.dart';
import 'auth_datasource.dart';

/// In-memory stand-in for the backend, following the same contract: same
/// JSON shape, same error codes, a small network-like delay.
///
/// Demo account: laila@example.com / Aswan2026. Reset code: 1234.
class AuthMockDataSource implements AuthDataSource {
  AuthMockDataSource({this.delay = const Duration(milliseconds: 600)});

  final Duration delay;

  static const String demoCode = '1234';

  final Map<String, _MockUser> _users = {
    'laila@example.com': _MockUser(
      id: 'u_1',
      fullName: 'Laila Hassan',
      password: 'Aswan2026',
      hasPreferences: true,
      avatarUrl: AppImages.avatarLaila,
    ),
  };
  int _nextId = 2;

  String _key(String identifier) => identifier.trim().toLowerCase();

  Map<String, dynamic> _authJson(
    String id,
    String name,
    String identifier, {
    bool hasPreferences = false,
    String? avatarUrl,
  }) => {
    'data': {
      'user': {
        'id': id,
        'full_name': name,
        'identifier': identifier,
        'has_preferences': hasPreferences,
        'avatar_url': avatarUrl,
      },
      'access_token': 'mock-access-$id',
      'refresh_token': 'mock-refresh-$id',
    },
  };

  @override
  Future<AuthResponseDto> login({
    required String identifier,
    required String password,
  }) async {
    await Future<void>.delayed(delay);
    final user = _users[_key(identifier)];
    if (user == null || user.password != password) {
      throw const AppException(
        code: ErrorCodes.invalidCredentials,
        statusCode: 401,
      );
    }
    return AuthResponseDto.fromJson(
      _authJson(
        user.id,
        user.fullName,
        _key(identifier),
        hasPreferences: user.hasPreferences,
        avatarUrl: user.avatarUrl,
      ),
    );
  }

  @override
  Future<AuthResponseDto> register({
    required String fullName,
    required String identifier,
    required String password,
  }) async {
    await Future<void>.delayed(delay);
    final key = _key(identifier);
    if (_users.containsKey(key)) {
      throw const AppException(
        code: ErrorCodes.emailAlreadyExists,
        statusCode: 409,
        details: {'identifier': ErrorCodes.emailAlreadyExists},
      );
    }
    final id = 'u_${_nextId++}';
    _users[key] = _MockUser(id: id, fullName: fullName, password: password);
    return AuthResponseDto.fromJson(_authJson(id, fullName, key));
  }

  @override
  Future<void> forgotPassword({required String identifier}) async {
    await Future<void>.delayed(delay);
    if (!_users.containsKey(_key(identifier))) {
      throw const AppException(
        code: ErrorCodes.userNotFound,
        statusCode: 404,
        details: {'identifier': ErrorCodes.userNotFound},
      );
    }
  }

  @override
  Future<void> resetPassword({
    required String identifier,
    required String code,
    required String newPassword,
  }) async {
    await Future<void>.delayed(delay);
    final user = _users[_key(identifier)];
    if (user == null) {
      throw const AppException(code: ErrorCodes.userNotFound, statusCode: 404);
    }
    if (code != demoCode) {
      throw const AppException(
        code: ErrorCodes.invalidCode,
        statusCode: 422,
        details: {'code': ErrorCodes.invalidCode},
      );
    }
    user.password = newPassword;
  }

  @override
  Future<void> logout() => Future<void>.delayed(delay);
}

class _MockUser {
  _MockUser({
    required this.id,
    required this.fullName,
    required this.password,
    this.hasPreferences = false,
    this.avatarUrl,
  });

  final String id;
  final String fullName;
  final bool hasPreferences;
  final String? avatarUrl;
  String password;
}
