import 'package:aswani/core/errors/failure.dart';
import 'package:aswani/core/result/result.dart';
import 'package:aswani/core/storage/key_value_store.dart';
import 'package:aswani/features/auth/data/datasources/auth_mock_datasource.dart';
import 'package:aswani/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MemoryKeyValueStore tokens;

  setUp(() {
    tokens = MemoryKeyValueStore();
    repository = AuthRepositoryImpl(
      AuthMockDataSource(delay: Duration.zero),
      tokens,
    );
  });

  test('signs in the demo user, who already has preferences', () async {
    final result = await repository.signIn(
      identifier: 'Laila@Example.com',
      password: 'Aswan2026',
    );
    final user = (result as Success).value;
    expect(user.firstName, 'Laila');
    expect(user.hasPreferences, isTrue);
    expect(user.avatarUrl, isNotNull);
    expect(await tokens.read(StorageKeys.accessToken), isNotNull);
    expect(await tokens.read(StorageKeys.refreshToken), isNotNull);
  });

  test('wrong password returns INVALID_CREDENTIALS', () async {
    final result = await repository.signIn(
      identifier: 'laila@example.com',
      password: 'wrong123',
    );
    expect((result as Error).failure.code, ErrorCodes.invalidCredentials);
  });

  test(
    'sign up with an existing email fails on the identifier field',
    () async {
      final result = await repository.signUp(
        fullName: 'Laila Hassan',
        identifier: 'laila@example.com',
        password: 'Aswan2026',
      );
      final failure = (result as Error).failure;
      expect(failure.code, ErrorCodes.emailAlreadyExists);
      expect(failure.fieldErrors['identifier'], ErrorCodes.emailAlreadyExists);
    },
  );

  test('new users start without preferences', () async {
    final result = await repository.signUp(
      fullName: 'Omar Ali',
      identifier: 'omar@example.com',
      password: 'Aswan2026',
    );
    expect((result as Success).value.hasPreferences, isFalse);
  });

  test('reset password checks the code, then the new password works', () async {
    final wrong = await repository.resetPassword(
      identifier: 'laila@example.com',
      code: '9999',
      newPassword: 'NewPass2026',
    );
    expect((wrong as Error).failure.code, ErrorCodes.invalidCode);

    final ok = await repository.resetPassword(
      identifier: 'laila@example.com',
      code: AuthMockDataSource.demoCode,
      newPassword: 'NewPass2026',
    );
    expect(ok, isA<Success<void>>());

    final signIn = await repository.signIn(
      identifier: 'laila@example.com',
      password: 'NewPass2026',
    );
    expect(signIn, isA<Success<Object?>>());
  });

  test('unknown account cannot request a reset code', () async {
    final result = await repository.requestPasswordReset(
      identifier: 'nobody@example.com',
    );
    expect((result as Error).failure.code, ErrorCodes.userNotFound);
  });
}
