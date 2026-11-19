import '../../../../core/assets/app_images.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/storage/key_value_store.dart';
import '../models/auth_response_dto.dart';
import '../models/user_dto.dart';
import 'auth_datasource.dart';

/// In-memory stand-in for the backend, following the same contract: same
/// JSON shape, same error codes, a small network-like delay.
///
/// Demo account: laila@example.com / Aswan2026. Reset code: 1234.
class AuthMockDataSource implements AuthDataSource {
  AuthMockDataSource({
    this.delay = const Duration(milliseconds: 600),
    this.tokens,
  });

  final Duration delay;

  /// Saved tokens, so `me()` still knows the user after a restart.
  final KeyValueStore? tokens;

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

  /// Last user who signed in or registered (stands in for the token).
  UserDto? _current;

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

  AuthResponseDto _remember(Map<String, dynamic> json) {
    final response = AuthResponseDto.fromJson(json);
    _current = response.user;
    return response;
  }

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
    return _remember(
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
    return _remember(_authJson(id, fullName, key));
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
  Future<void> logout() async {
    await Future<void>.delayed(delay);
    _current = null;
  }

  @override
  Future<UserDto> me() async {
    await Future<void>.delayed(delay);
    var user = _current;
    final token = await tokens?.read(StorageKeys.accessToken);
    if (user == null && token != null && token.startsWith('mock-access-')) {
      final id = token.substring('mock-access-'.length);
      for (final entry in _users.entries) {
        final u = entry.value;
        if (u.id != id) continue;
        user = UserDto(
          id: u.id,
          fullName: u.fullName,
          identifier: entry.key,
          hasPreferences: u.hasPreferences,
          avatarUrl: u.avatarUrl,
        );
      }
    }
    if (user == null) {
      throw const AppException(code: ErrorCodes.unauthorized, statusCode: 401);
    }
    return user;
  }
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
