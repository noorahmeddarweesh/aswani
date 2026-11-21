import '../l10n/generated/app_localizations.dart';
import 'failure.dart';

/// The one registry from error code to the message users see (Arabic and
/// English). A new code gets a line here before any screen uses it; the
/// user never sees a raw server message.
extension ErrorMessages on AppLocalizations {
  String errorFor(String code) => switch (code) {
    ErrorCodes.invalidCredentials => errorInvalidCredentials,
    ErrorCodes.emailAlreadyExists => errorEmailExists,
    ErrorCodes.userNotFound => errorUserNotFound,
    ErrorCodes.invalidCode => errorInvalidCode,
    ErrorCodes.noConnection => errorNoConnection,
    ErrorCodes.timeout => errorTimeout,
    ErrorCodes.serverError => errorServer,
    ErrorCodes.unauthorized => errorUnauthorized,
    ErrorCodes.placeNotFound => errorPlaceNotFound,
    ErrorCodes.validation => errorValidation,
    ErrorCodes.guideNotFound => errorGuideNotFound,
    ErrorCodes.dateInPast => errorDateInPast,
    ErrorCodes.alreadyApplied => errorAlreadyApplied,
    ErrorCodes.postNotFound => errorPostNotFound,
    ErrorCodes.commentNotFound => errorCommentNotFound,
    ErrorCodes.storyNotFound => errorStoryNotFound,
    ErrorCodes.forbidden => errorForbidden,
    ErrorCodes.tooManyPhotos => errorTooManyPhotos,
    ErrorCodes.fileTooLarge => errorFileTooLarge,
    ErrorCodes.unsupportedFileType => errorUnsupportedFile,
    ErrorCodes.invalidCurrentPassword => errorInvalidCurrentPassword,
    ErrorCodes.deletionAlreadyRequested => errorDeletionRequested,
    ErrorCodes.contributionNotFound => errorContributionNotFound,
    _ => errorUnknown,
  };
}
