/// Form rules that mirror the backend rules. They return an error key (not
/// text); the screen turns the key into a localised message.
enum ValidationError {
  required,
  identifier,
  password,
  passwordsMismatch,
  name,
  code,
}

abstract final class AuthValidators {
  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  /// Egyptian mobile: 01x xxxx xxxx, optionally with +20 / 0020.
  static final RegExp _egyptPhone = RegExp(r'^(\+20|0020|0)?1[0125]\d{8}$');

  static final RegExp _letter = RegExp(r'[A-Za-z؀-ۿ]');
  static final RegExp _digit = RegExp(r'\d');
  static final RegExp _code = RegExp(r'^\d{4}$');

  static ValidationError? identifier(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return ValidationError.required;
    final digits = v.replaceAll(RegExp(r'[\s-]'), '');
    if (_email.hasMatch(v) || _egyptPhone.hasMatch(digits)) return null;
    return ValidationError.identifier;
  }

  static ValidationError? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return ValidationError.required;
    if (v.length < 8 || !_letter.hasMatch(v) || !_digit.hasMatch(v)) {
      return ValidationError.password;
    }
    return null;
  }

  /// Sign-in only checks that a password was typed; strength rules apply
  /// when creating or changing it.
  static ValidationError? requiredField(String? value) =>
      (value ?? '').isEmpty ? ValidationError.required : null;

  static ValidationError? confirmPassword(String? value, String password) {
    if ((value ?? '').isEmpty) return ValidationError.required;
    return value == password ? null : ValidationError.passwordsMismatch;
  }

  static ValidationError? fullName(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return ValidationError.required;
    return v.length < 3 ? ValidationError.name : null;
  }

  static ValidationError? code(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return ValidationError.required;
    return _code.hasMatch(v) ? null : ValidationError.code;
  }
}
