import 'package:aswani/features/auth/presentation/validators/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('identifier', () {
    test('accepts emails and Egyptian mobile numbers', () {
      expect(AuthValidators.identifier('laila@example.com'), isNull);
      expect(AuthValidators.identifier('01012345678'), isNull);
      expect(AuthValidators.identifier('+201112345678'), isNull);
      expect(AuthValidators.identifier('010 1234 5678'), isNull);
    });

    test('rejects empty and malformed values', () {
      expect(AuthValidators.identifier(''), ValidationError.required);
      expect(AuthValidators.identifier('laila@'), ValidationError.identifier);
      expect(AuthValidators.identifier('0101234'), ValidationError.identifier);
    });
  });

  test('sign-up email accepts emails only', () {
    expect(AuthValidators.email('omar@example.com'), isNull);
    expect(AuthValidators.email('01012345678'), ValidationError.email);
    expect(AuthValidators.email(''), ValidationError.required);
  });

  test('password needs 8+ characters with letters and numbers', () {
    expect(AuthValidators.password(''), ValidationError.required);
    expect(AuthValidators.password('short1'), ValidationError.password);
    expect(AuthValidators.password('onlyletters'), ValidationError.password);
    expect(AuthValidators.password('12345678'), ValidationError.password);
    expect(AuthValidators.password('Aswan2026'), isNull);
  });

  test('confirm password must match', () {
    expect(
      AuthValidators.confirmPassword('Aswan2025', 'Aswan2026'),
      ValidationError.passwordsMismatch,
    );
    expect(AuthValidators.confirmPassword('Aswan2026', 'Aswan2026'), isNull);
  });

  test('full name and code', () {
    expect(AuthValidators.fullName('Al'), ValidationError.name);
    expect(AuthValidators.fullName('Laila Hassan'), isNull);
    expect(AuthValidators.code('12a4'), ValidationError.code);
    expect(AuthValidators.code('1234'), isNull);
  });
}
