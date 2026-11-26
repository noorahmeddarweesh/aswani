import 'package:aswani/core/errors/app_exception.dart';
import 'package:aswani/core/storage/key_value_store.dart';
import 'package:aswani/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_api.dart';

const _user = {
  'id': 'u_1',
  'full_name': 'Laila Hassan',
  'identifier': 'laila@example.com',
  'has_preferences': true,
};

void main() {
  late FakeApi api;
  late MemoryKeyValueStore tokens;
  late AuthRemoteDataSource remote;

  setUp(() {
    api = FakeApi((_) => reply(204));
    tokens = MemoryKeyValueStore();
    remote = AuthRemoteDataSource(api.client(), tokens);
  });

  test('login posts the contract body and reads the auth response', () async {
    api.handler = (_) => reply(200, {
      'data': {'user': _user, 'access_token': 'a', 'refresh_token': 'r'},
    });

    final response = await remote.login(
      identifier: 'laila@example.com',
      password: 'Aswan2026',
    );

    final request = api.requests.single;
    expect(request.method, 'POST');
    expect(request.uri.toString(), 'https://api.test/api/auth/login');
    expect(request.data, {
      'identifier': 'laila@example.com',
      'password': 'Aswan2026',
    });
    expect(response.user.fullName, 'Laila Hassan');
    expect(response.accessToken, 'a');
  });

  test('register sends full_name in snake_case', () async {
    api.handler = (_) => reply(201, {
      'data': {'user': _user, 'access_token': 'a', 'refresh_token': 'r'},
    });
    await remote.register(
      fullName: 'Laila Hassan',
      identifier: 'laila@example.com',
      password: 'Aswan2026',
    );
    expect(api.requests.single.path, '/auth/register');
    expect(api.requests.single.data, {
      'full_name': 'Laila Hassan',
      'identifier': 'laila@example.com',
      'password': 'Aswan2026',
    });
  });

  test('a contract error becomes AppException with field details', () async {
    api.handler = (_) => reply(
      409,
      apiError('EMAIL_ALREADY_EXISTS', {'identifier': 'EMAIL_ALREADY_EXISTS'}),
    );
    await expectLater(
      remote.register(
        fullName: 'Laila',
        identifier: 'laila@example.com',
        password: 'Aswan2026',
      ),
      throwsA(
        isA<AppException>()
            .having((e) => e.code, 'code', 'EMAIL_ALREADY_EXISTS')
            .having((e) => e.statusCode, 'status', 409)
            .having((e) => e.details, 'details', {
              'identifier': 'EMAIL_ALREADY_EXISTS',
            }),
      ),
    );
  });

  test('forgot and reset password follow the contract', () async {
    await remote.forgotPassword(identifier: 'laila@example.com');
    await remote.resetPassword(
      identifier: 'laila@example.com',
      code: '1234',
      newPassword: 'Nile2026x',
    );
    expect(api.requests.map((r) => r.path), [
      '/auth/forgot-password',
      '/auth/reset-password',
    ]);
    expect(api.requests.last.data, {
      'identifier': 'laila@example.com',
      'code': '1234',
      'new_password': 'Nile2026x',
    });
  });

  test('logout sends the saved refresh token; me reads the user', () async {
    await tokens.write(StorageKeys.refreshToken, 'r1');
    await remote.logout();
    expect(api.requests.single.path, '/auth/logout');
    expect(api.requests.single.data, {'refresh_token': 'r1'});

    api.handler = (_) => reply(200, {'data': _user});
    final me = await remote.me();
    expect(api.requests.last.method, 'GET');
    expect(api.requests.last.path, '/users/me');
    expect(me.hasPreferences, isTrue);
  });
}
