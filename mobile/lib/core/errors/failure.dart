import 'app_exception.dart';

/// Error codes shared by the whole app. Feature-specific codes come from the
/// API contract; network-level ones are produced by the app itself.
abstract final class ErrorCodes {
  static const String validation = 'VALIDATION_ERROR';
  static const String invalidCredentials = 'INVALID_CREDENTIALS';
  static const String emailAlreadyExists = 'EMAIL_ALREADY_EXISTS';
  static const String userNotFound = 'USER_NOT_FOUND';
  static const String invalidCode = 'INVALID_CODE';
  static const String unauthorized = 'UNAUTHORIZED';
  static const String placeNotFound = 'PLACE_NOT_FOUND';
  static const String noConnection = 'NO_CONNECTION';
  static const String timeout = 'TIMEOUT';
  static const String serverError = 'SERVER_ERROR';
  static const String unknown = 'UNKNOWN';
}

/// What the UI receives when something goes wrong. The screen turns [code]
/// into a localised message; it never shows a raw server message.
class Failure {
  const Failure(this.code, {this.fieldErrors = const {}});

  factory Failure.fromException(AppException e) =>
      Failure(e.code, fieldErrors: e.details);

  static const Failure unknown = Failure(ErrorCodes.unknown);

  final String code;

  /// Field name -> error code, shown under the matching form field.
  final Map<String, String> fieldErrors;

  @override
  bool operator ==(Object other) => other is Failure && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'Failure($code)';
}
