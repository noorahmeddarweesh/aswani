export '../../../core/errors/error_messages.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import 'validators/auth_validators.dart';

/// Turns auth validation keys into localised messages; error codes are in
/// `core/errors/error_messages.dart`.
extension AuthErrorText on AppLocalizations {
  String? validation(ValidationError? error) => switch (error) {
    null => null,
    ValidationError.required => validationRequired,
    ValidationError.identifier => validationIdentifier,
    ValidationError.email => validationEmail,
    ValidationError.password => validationPassword,
    ValidationError.passwordsMismatch => validationPasswordsMismatch,
    ValidationError.name => validationName,
    ValidationError.code => validationCode,
  };
}
