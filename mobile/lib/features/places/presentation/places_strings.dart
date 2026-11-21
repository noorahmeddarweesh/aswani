import 'package:aswani/features/places/domain/entities/place_report.dart';
import 'package:material_ui/material_ui.dart';

/// Localized strings for the Place Details & Place Report features per API Contract v0.2 and Figma design.
/// Uses 'place_' prefix for place strings and 'report_' prefix for report strings.
class PlacesStrings {
  const PlacesStrings._({required this.isArabic});

  final bool isArabic;

  static PlacesStrings of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar' ||
        Directionality.of(context) == TextDirection.rtl;
    return PlacesStrings._(isArabic: isArabic);
  }

  static PlacesStrings forLocale(Locale locale) {
    return PlacesStrings._(isArabic: locale.languageCode == 'ar');
  }

  // --- Place Details (place_ prefix) ---

  /// Eyebrow displayed above place title: 'HISTORICAL PLACE' / 'موقع تاريخي'
  String get placeEyebrow => isArabic ? 'موقع تاريخي' : 'HISTORICAL PLACE';
  String get eyebrow => placeEyebrow;

  /// Section heading for 'About this place' / 'عن هذا المكان'
  String get placeAboutTitle => isArabic ? 'عن هذا المكان' : 'About this place';
  String get aboutTitle => placeAboutTitle;

  /// Visiting information card title: 'Visiting information' / 'معلومات الزيارة'
  String get placeVisitingInfoTitle =>
      isArabic ? 'معلومات الزيارة' : 'Visiting information';
  String get visitingInfoTitle => placeVisitingInfoTitle;

  /// Visiting information subtitle notice
  String get placeVisitingInfoSubtitle => isArabic
      ? 'ساعات العمل والأسعار غير المؤكدة محجوبة عمدًا.'
      : 'Unverified hours and prices are intentionally not shown.';
  String get visitingInfoSubtitle => placeVisitingInfoSubtitle;

  /// 404 error message
  String get placeNotFound => isArabic ? 'المكان غير موجود.' : 'Place not found.';

  /// Generic error message
  String get placeGenericError => isArabic
      ? 'حدث خطأ ما. يرجى المحاولة مرة أخرى.'
      : 'Something went wrong. Please try again.';

  /// Retry button label
  String get placeRetry => isArabic ? 'إعادة المحاولة' : 'Try again';
  String get retry => placeRetry;

  /// Back button tooltip / label
  String get placeBack => isArabic ? 'رجوع' : 'Back';
  String get back => placeBack;

  /// Share action tooltip
  String get placeShare => isArabic ? 'مشاركة' : 'Share';
  String get share => placeShare;

  /// Share feedback message
  String get placeShareCopied =>
      isArabic ? 'تم نسخ الرابط إلى الحافظة' : 'Link copied to clipboard';

  /// Bookmark action tooltip (add)
  String get placeBookmarkAdd => isArabic ? 'حفظ المكان' : 'Save place';
  String get bookmarkAdd => placeBookmarkAdd;

  /// Bookmark action tooltip (remove)
  String get placeBookmarkRemove => isArabic ? 'إزالة الحفظ' : 'Remove bookmark';
  String get bookmarkRemove => placeBookmarkRemove;

  // --- Place Report Flow (report_ prefix) ---

  /// Report inaccurate information link: 'See something inaccurate? Report it.'
  String get reportRowText => isArabic
      ? 'هل ترى معلومات غير دقيقة؟ أبلغ عنها.'
      : 'See something inaccurate? Report it.';
  String get reportRow => reportRowText;

  // Screen 9: What Needs Updating
  String get reportTitle => isArabic ? 'الإبلاغ عن مكان' : 'Report a place';
  String get reportEyebrow =>
      isArabic ? 'ساعد في تحسين الدليل' : 'HELP IMPROVE THE GUIDE';
  String get reportWhatNeedsUpdating =>
      isArabic ? 'ما الذي يحتاج إلى تحديث؟' : 'What needs updating?';
  String get reportSubtitle => isArabic
      ? 'اختر السبب الأكثر تطابقًا مع ما وجدته.'
      : 'Choose the reason that best matches what you found.';

  String reasonLabel(PlaceReportReason reason) {
    switch (reason) {
      case PlaceReportReason.notExist:
        return isArabic ? 'المكان غير موجود' : 'Place does not exist';
      case PlaceReportReason.permanentlyClosed:
        return isArabic ? 'مغلق نهائيًا' : 'Permanently closed';
      case PlaceReportReason.temporarilyClosed:
        return isArabic ? 'مغلق مؤقتًا' : 'Temporarily closed';
      case PlaceReportReason.incorrectLocation:
        return isArabic ? 'الموقع غير صحيح' : 'Incorrect location';
      case PlaceReportReason.incorrectInformation:
        return isArabic ? 'المعلومات غير صحيحة' : 'Incorrect information';
      case PlaceReportReason.other:
        return isArabic ? 'أخرى' : 'Other';
    }
  }

  String get reportContinue => isArabic ? 'متابعة' : 'Continue';

  // Screen 10: Report Details
  String get reportDetailsTitle => isArabic ? 'تفاصيل البلاغ' : 'Report details';
  String get reportSelectedPlace =>
      isArabic ? 'المكان المحدد' : 'SELECTED PLACE';
  String get reportTellUs =>
      isArabic ? 'أخبرنا بما وجدته *' : 'Tell us what you found *';
  String get reportDetailsHint => isArabic
      ? 'أضف تفاصيل تساعد فريق المراجعة...'
      : 'Add details that help the review team...';
  String get reportAddPhoto =>
      isArabic ? 'إضافة صورة داعمة' : 'Add supporting photo';
  String get reportPhotoOptional => isArabic ? 'اختياري' : 'Optional';
  String get reportRemovePhoto => isArabic ? 'إزالة الصورة' : 'Remove photo';
  String get reportNoticeTitle =>
      isArabic ? 'تتم مراجعة كل بلاغ' : 'Every report is reviewed';
  String get reportNoticeSubtitle => isArabic
      ? 'تُمنح النقاط فقط بعد قبول البلاغ.'
      : 'Points are awarded only after acceptance.';
  String get reportSubmit => isArabic ? 'إرسال البلاغ' : 'Submit report';

  // Screen 10 Validation Errors
  String get reportDetailsRequired => isArabic
      ? 'يرجى تقديم تفاصيل عما يحتاج إلى تحديث'
      : 'Please provide details about what needs updating';
  String get reportDetailsTooLong => isArabic
      ? 'يجب ألا تتجاوز التفاصيل 1000 حرف'
      : 'Details must be 1000 characters or fewer';
  String get reportPhotoTooLarge => isArabic
      ? 'حجم الصورة يتجاوز الحد الأقصى 5 ميجابايت'
      : 'Photo exceeds 5 MB limit';
  String get reportPhotoUnsupported => isArabic
      ? 'يتم دعم صور JPG و PNG و WebP فقط'
      : 'Only JPG, PNG, and WebP photos are supported';

  // Screen 11: Report Under Review (Submitted)
  String get reportUnderReviewEyebrow =>
      isArabic ? 'قيد المراجعة' : 'UNDER REVIEW';
  String get reportThankYou => isArabic
      ? 'شكرًا لمساعدتك في الحفاظ على دقة أسواني'
      : 'Thank you for helping keep ASWANI accurate';
  String get reportDoneSubtitle => isArabic
      ? 'تقريرك لدى فريق المراجعة. تُمنح النقاط فقط في حال قبول المعلومات.'
      : 'Your report is with the review team. Points are awarded only if the information is accepted.';
  String get reportPointsValue => '+25';
  String get reportPointsPending =>
      isArabic ? 'نقطة معلقة' : 'points pending';
  String get reportPendingReview =>
      isArabic ? 'قيد المراجعة' : 'Pending review';

  // 3-Step Timeline
  String get reportStepSubmitted => isArabic ? 'تم الإرسال' : 'Submitted';
  String get reportStepUnderReview =>
      isArabic ? 'قيد المراجعة' : 'Under review';
  String get reportStepPoints =>
      isArabic ? 'نقاط بعد القبول' : 'Points after acceptance';
  String get reportTimelineCaption => isArabic
      ? 'تم الإرسال • قيد المراجعة • نقاط بعد القبول'
      : 'Submitted • Under review • Points after acceptance';

  String get reportDoneButton => isArabic ? 'تم' : 'Done';

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
