/// Thrown by data sources (remote or mock) when the API answers with an
/// error, using the contract's error shape:
/// `{ "error": { "code", "message", "details": { "field": "..." } } }`.
///
/// Repositories catch it and turn it into a [Failure]; it never reaches the UI.
class AppException implements Exception {
  const AppException({
    required this.code,
    this.message = '',
    this.details = const {},
    this.statusCode,
  });

  /// Contract error code, e.g. `VALIDATION_ERROR`, `INVALID_CREDENTIALS`.
  final String code;

  /// Server message, for logs only. Never shown to the user.
  final String message;

  /// Field-level errors: field name -> error code.
  final Map<String, String> details;

  final int? statusCode;

  @override
  String toString() => 'AppException($code, $statusCode): $message';
}
