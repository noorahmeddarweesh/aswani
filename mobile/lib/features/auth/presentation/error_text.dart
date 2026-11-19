import '../../../core/errors/failure.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import 'validators/auth_validators.dart';

/// Turns error codes and validation keys into localised messages.
/// The user never sees a raw server message.
extension AuthErrorText on AppLocalizations {
  String errorFor(String code) => switch (code) {
    ErrorCodes.invalidCredentials => errorInvalidCredentials,
    ErrorCodes.emailAlreadyExists => errorEmailExists,
    ErrorCodes.userNotFound => errorUserNotFound,
    ErrorCodes.invalidCode => errorInvalidCode,
    ErrorCodes.noConnection => errorNoConnection,
    ErrorCodes.timeout => errorTimeout,
    ErrorCodes.serverError => errorServer,
    _ => errorUnknown,
  };

  String? validation(ValidationError? error) => switch (error) {
    null => null,
    ValidationError.required => validationRequired,
    ValidationError.identifier => validationIdentifier,
    ValidationError.password => validationPassword,
    ValidationError.passwordsMismatch => validationPasswordsMismatch,
    ValidationError.name => validationName,
    ValidationError.code => validationCode,
  };
}
