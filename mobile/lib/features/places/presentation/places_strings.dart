import 'package:aswani/features/places/domain/entities/place_report.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/generated/app_localizations.dart';

/// Place Details and Report a place copy, read from the app's ARB files
/// (app_en.arb, app_ar.arb) so every feature translates the same way.
/// Uses 'place_' prefix for place strings and 'report_' prefix for report strings.
class PlacesStrings {
  PlacesStrings._(this._l, {required this.isArabic});

  final bool isArabic;
  final AppLocalizations _l;

  static PlacesStrings of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isArabic =
        locale.languageCode == 'ar' ||
        Directionality.of(context) == TextDirection.rtl;
    return PlacesStrings._(AppLocalizations.of(context), isArabic: isArabic);
  }

  static PlacesStrings forLocale(Locale locale) {
    return PlacesStrings._(
      lookupAppLocalizations(locale),
      isArabic: locale.languageCode == 'ar',
    );
  }

  // --- Place Details (place_ prefix) ---

  /// Eyebrow displayed above place title: 'HISTORICAL PLACE' / 'موقع تاريخي'
  String get placeEyebrow => _l.placeEyebrow;
  String get eyebrow => placeEyebrow;

  /// Section heading for 'About this place' / 'عن هذا المكان'
  String get placeAboutTitle => _l.placeAboutTitle;
  String get aboutTitle => placeAboutTitle;

  /// Visiting information card title: 'Visiting information' / 'معلومات الزيارة'
  String get placeVisitingInfoTitle => _l.placeVisitingInfoTitle;
  String get visitingInfoTitle => placeVisitingInfoTitle;

  /// Visiting information subtitle notice
  String get placeVisitingInfoSubtitle => _l.placeVisitingInfoSubtitle;
  String get visitingInfoSubtitle => placeVisitingInfoSubtitle;

  /// 404 error message
  String get placeNotFound => _l.placeNotFound;

  /// Generic error message
  String get placeGenericError => _l.placeGenericError;

  /// Retry button label
  String get placeRetry => _l.placeRetry;
  String get retry => placeRetry;

  /// Back button tooltip / label
  String get placeBack => _l.placeBack;
  String get back => placeBack;

  /// Share action tooltip
  String get placeShare => _l.placeShare;
  String get share => placeShare;

  /// Share feedback message
  String get placeShareCopied => _l.placeShareCopied;

  /// Bookmark action tooltip (add)
  String get placeBookmarkAdd => _l.placeBookmarkAdd;
  String get bookmarkAdd => placeBookmarkAdd;

  /// Bookmark action tooltip (remove)
  String get placeBookmarkRemove => _l.placeBookmarkRemove;
  String get bookmarkRemove => placeBookmarkRemove;

  // --- Place Report Flow (report_ prefix) ---

  /// Report inaccurate information link: 'See something inaccurate? Report it.'
  String get reportRowText => _l.placeReportRowText;
  String get reportRow => reportRowText;

  // Screen 9: What Needs Updating
  String get reportTitle => _l.placeReportTitle;
  String get reportEyebrow => _l.placeReportEyebrow;
  String get reportWhatNeedsUpdating => _l.placeReportWhatNeedsUpdating;
  String get reportSubtitle => _l.placeReportSubtitle;

  String reasonLabel(PlaceReportReason reason) {
    switch (reason) {
      case PlaceReportReason.notExist:
        return _l.placeReasonLabelNotExist;
      case PlaceReportReason.permanentlyClosed:
        return _l.placeReasonLabelPermanentlyClosed;
      case PlaceReportReason.temporarilyClosed:
        return _l.placeReasonLabelTemporarilyClosed;
      case PlaceReportReason.incorrectLocation:
        return _l.placeReasonLabelIncorrectLocation;
      case PlaceReportReason.incorrectInformation:
        return _l.placeReasonLabelIncorrectInformation;
      case PlaceReportReason.other:
        return _l.placeReasonLabelOther;
    }
  }

  String get reportContinue => _l.placeReportContinue;

  // Screen 10: Report Details
  String get reportDetailsTitle => _l.placeReportDetailsTitle;
  String get reportSelectedPlace => _l.placeReportSelectedPlace;
  String get reportTellUs => _l.placeReportTellUs;
  String get reportDetailsHint => _l.placeReportDetailsHint;
  String get reportAddPhoto => _l.placeReportAddPhoto;
  String get reportPhotoOptional => _l.placeReportPhotoOptional;
  String get reportRemovePhoto => _l.placeReportRemovePhoto;
  String get reportNoticeTitle => _l.placeReportNoticeTitle;
  String get reportNoticeSubtitle => _l.placeReportNoticeSubtitle;
  String get reportSubmit => _l.placeReportSubmit;

  // Screen 10 Validation Errors
  String get reportDetailsRequired => _l.placeReportDetailsRequired;
  String get reportDetailsTooLong => _l.placeReportDetailsTooLong;
  String get reportPhotoTooLarge => _l.placeReportPhotoTooLarge;
  String get reportPhotoUnsupported => _l.placeReportPhotoUnsupported;

  // Screen 11: Report Under Review (Submitted)
  String get reportUnderReviewEyebrow => _l.placeReportUnderReviewEyebrow;
  String get reportThankYou => _l.placeReportThankYou;
  String get reportDoneSubtitle => _l.placeReportDoneSubtitle;
  String get reportPointsValue => '+25';
  String get reportPointsPending => _l.placeReportPointsPending;
  String get reportPendingReview => _l.placeReportPendingReview;

  // 3-Step Timeline
  String get reportStepSubmitted => _l.placeReportStepSubmitted;
  String get reportStepUnderReview => _l.placeReportStepUnderReview;
  String get reportStepPoints => _l.placeReportStepPoints;
  String get reportTimelineCaption => _l.placeReportTimelineCaption;

  String get reportDoneButton => _l.placeReportDoneButton;

  // Key-based lookup supporting exact 'place_' and 'report_' prefixes.
  String tr(String key) {
    switch (key) {
      case 'place_eyebrow':
        return placeEyebrow;
      case 'place_about_title':
        return placeAboutTitle;
      case 'place_visiting_info_title':
        return placeVisitingInfoTitle;
      case 'place_visiting_info_subtitle':
        return placeVisitingInfoSubtitle;
      case 'place_not_found':
        return placeNotFound;
      case 'place_generic_error':
        return placeGenericError;
      case 'place_retry':
        return placeRetry;
      case 'place_back':
        return placeBack;
      case 'place_share':
        return placeShare;
      case 'place_share_copied':
        return placeShareCopied;
      case 'place_bookmark_add':
        return placeBookmarkAdd;
      case 'place_bookmark_remove':
        return placeBookmarkRemove;
      case 'report_row_text':
        return reportRowText;
      case 'report_title':
        return reportTitle;
      case 'report_eyebrow':
        return reportEyebrow;
      case 'report_what_needs_updating':
        return reportWhatNeedsUpdating;
      case 'report_subtitle':
        return reportSubtitle;
      case 'report_continue':
        return reportContinue;
      case 'report_details_title':
        return reportDetailsTitle;
      case 'report_selected_place':
        return reportSelectedPlace;
      case 'report_tell_us':
        return reportTellUs;
      case 'report_details_hint':
        return reportDetailsHint;
      case 'report_add_photo':
        return reportAddPhoto;
      case 'report_photo_optional':
        return reportPhotoOptional;
      case 'report_remove_photo':
        return reportRemovePhoto;
      case 'report_notice_title':
        return reportNoticeTitle;
      case 'report_notice_subtitle':
        return reportNoticeSubtitle;
      case 'report_submit':
        return reportSubmit;
      case 'report_details_required':
        return reportDetailsRequired;
      case 'report_details_too_long':
        return reportDetailsTooLong;
      case 'report_photo_too_large':
        return reportPhotoTooLarge;
      case 'report_photo_unsupported':
        return reportPhotoUnsupported;
      case 'report_under_review_eyebrow':
        return reportUnderReviewEyebrow;
      case 'report_thank_you':
        return reportThankYou;
      case 'report_done_subtitle':
        return reportDoneSubtitle;
      case 'report_points_value':
        return reportPointsValue;
      case 'report_points_pending':
        return reportPointsPending;
      case 'report_pending_review':
        return reportPendingReview;
      case 'report_step_submitted':
        return reportStepSubmitted;
      case 'report_step_under_review':
        return reportStepUnderReview;
      case 'report_step_points':
        return reportStepPoints;
      case 'report_timeline_caption':
        return reportTimelineCaption;
      case 'report_done_button':
        return reportDoneButton;
      default:
        return key;
    }
  }
}
