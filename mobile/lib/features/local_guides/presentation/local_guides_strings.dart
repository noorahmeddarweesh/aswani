import 'package:aswani/features/local_guides/domain/entities/guide_enums.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/generated/app_localizations.dart';

/// Local Guides copy, read from the app's ARB files (app_en.arb,
/// app_ar.arb) so every feature translates the same way.
/// Provides English and Arabic copy matching tour_guides.jpg and design_spec.txt
/// without modifying core ARB files during Phase 1.
class LocalGuidesStrings {
  LocalGuidesStrings._(this._l, {required this.isArabic});

  /// Only for formats the ARB files cannot hold (the review date).
  final bool isArabic;
  final AppLocalizations _l;

  static LocalGuidesStrings of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isArabic =
        locale.languageCode == 'ar' ||
        Directionality.of(context) == TextDirection.rtl;
    return LocalGuidesStrings._(
      AppLocalizations.of(context),
      isArabic: isArabic,
    );
  }

  // Screen header
  String get eyebrow => _l.guidesEyebrow;
  String get title => _l.guidesTitle;
  String get subtitle => _l.guidesSubtitle;

  // Search
  String get searchHint => _l.guidesSearchHint;

  // Specialty chips
  String get filterAll => _l.guidesFilterAll;
  String specialtyLabel(GuideSpecialty specialty) {
    switch (specialty) {
      case GuideSpecialty.nubianCulture:
        return _l.guidesSpecialtyLabelNubianCulture;
      case GuideSpecialty.historicalSites:
        return _l.guidesSpecialtyLabelHistoricalSites;
      case GuideSpecialty.nile:
        return _l.guidesSpecialtyLabelNile;
      case GuideSpecialty.photography:
        return _l.guidesSpecialtyLabelPhotography;
      case GuideSpecialty.localExperiences:
        return _l.guidesSpecialtyLabelLocalExperiences;
    }
  }

  // Featured guide card
  String get sampleProfile => _l.guidesSampleProfile;
  String durationLabel(GuideDuration duration) {
    switch (duration) {
      case GuideDuration.fewHours:
        return _l.guidesDurationLabelFewHours;
      case GuideDuration.oneDay:
        return _l.guidesDurationLabelOneDay;
      case GuideDuration.multipleDays:
        return _l.guidesDurationLabelMultipleDays;
    }
  }

  // Suggested guides section
  String get suggestedSectionTitle => _l.guidesSuggestedSectionTitle;
  String get filterAction => _l.guidesFilterAction;
  String get illustrativeNote => _l.guidesIllustrativeNote;

  // CTA Card
  String get ctaTitle => _l.guidesCtaTitle;
  String get ctaSubtitle => _l.guidesCtaSubtitle;

  // States
  String get emptySearch => _l.guidesEmptySearch;
  String get emptyFilter => _l.guidesEmptyFilter;
  String get errorLoading => _l.guidesErrorLoading;
  String get retry => _l.guidesRetry;

  // Guide Details Screen (P4)
  String get guidesSampleProfileNotVerified =>
      _l.guidesSampleProfileNotVerified;
  String get sampleProfileNotVerified => guidesSampleProfileNotVerified;

  String get guidesSpecialties => _l.guidesSpecialties;
  String get specialtiesHeader => guidesSpecialties;

  String get guidesAvailableTourDurations => _l.guidesAvailableTourDurations;
  String get availableDurationsHeader => guidesAvailableTourDurations;

  String get guidesNoticeTitle => _l.guidesNoticeTitle;
  String get noticeTitle => guidesNoticeTitle;

  String get guidesNoticeSubtitle => _l.guidesNoticeSubtitle;
  String get noticeSubtitle => guidesNoticeSubtitle;

  String get guidesRequestThisGuide => _l.guidesRequestThisGuide;
  String get requestThisGuide => guidesRequestThisGuide;

  String get guidesNotFound => _l.guidesNotFound;
  String get guideNotFound => guidesNotFound;

  String get guidesBack => _l.guidesBack;
  String get back => guidesBack;

  String get guidesShare => _l.guidesShare;
  String get share => guidesShare;

  String languageLabel(GuideLanguage language) {
    switch (language) {
      case GuideLanguage.ar:
        return _l.guidesLanguageLabelAr;
      case GuideLanguage.en:
        return _l.guidesLanguageLabelEn;
      case GuideLanguage.fr:
        return _l.guidesLanguageLabelFr;
      case GuideLanguage.de:
        return _l.guidesLanguageLabelDe;
      case GuideLanguage.it:
        return _l.guidesLanguageLabelIt;
      case GuideLanguage.es:
        return _l.guidesLanguageLabelEs;
    }
  }

  String languagesFormatted(List<GuideLanguage> languages) {
    return languages.map(languageLabel).join(_l.guidesLanguagesJoiner);
  }

  String detailsSpecialtyLabel(GuideSpecialty specialty) {
    if (specialty == GuideSpecialty.historicalSites) {
      return _l.guidesDetailsSpecialtyLabelHistoricalSites;
    }
    return specialtyLabel(specialty);
  }

  String detailsDurationLabel(GuideDuration duration) {
    switch (duration) {
      case GuideDuration.fewHours:
        return _l.guidesDetailsDurationLabelFewHours;
      case GuideDuration.oneDay:
        return _l.guidesDetailsDurationLabelOneDay;
      case GuideDuration.multipleDays:
        return _l.guidesDetailsDurationLabelMultipleDays;
    }
  }

  // Request a Guide Form (P5)
  String get requestScreenTitle => _l.guidesRequestScreenTitle;
  String get requestIntro => _l.guidesRequestIntro;
  String get requestPreferredDate => _l.guidesRequestPreferredDate;
  String get requestSelectDate => _l.guidesRequestSelectDate;
  String get requestTourDuration => _l.guidesRequestTourDuration;

  String requestDurationLabel(RequestDuration duration) {
    switch (duration) {
      case RequestDuration.fewHours:
        return _l.guidesRequestDurationLabelFewHours;
      case RequestDuration.oneDay:
        return _l.guidesRequestDurationLabelOneDay;
      case RequestDuration.twoDays:
        return _l.guidesRequestDurationLabelTwoDays;
      case RequestDuration.threeDays:
        return _l.guidesRequestDurationLabelThreeDays;
      case RequestDuration.custom:
        return _l.guidesRequestDurationLabelCustom;
    }
  }

  String get requestStartTime => _l.guidesRequestStartTime;
  String get requestGroupSize => _l.guidesRequestGroupSize;
  String requestGroupSizeFormatted(int count) => _l.guidesGroupSize(count);

  String get requestPreferredLanguage => _l.guidesRequestPreferredLanguage;
  String get requestAdditionalNotes => _l.guidesRequestAdditionalNotes;
  String get requestNotesHint => _l.guidesRequestNotesHint;
  String get requestReviewButton => _l.guidesRequestReviewButton;

  // Validation & Helpers
  String get requestDateRequired => _l.guidesRequestDateRequired;
  String get requestDateInPast => _l.guidesRequestDateInPast;
  String get requestCustomHoursRequired => _l.guidesRequestCustomHoursRequired;
  String get requestCustomDurationLabel => _l.guidesRequestCustomDurationLabel;
  String requestHoursCount(int hours) => _l.guidesHoursCount(hours);

  // Review Request Screen (P6)
  String get reviewScreenTitle => _l.guidesReviewScreenTitle;
  String get selectedGuideEyebrow => _l.guidesSelectedGuideEyebrow;
  String get reviewSampleProfile => _l.guidesReviewSampleProfile;
  String get reviewDateLabel => _l.guidesReviewDateLabel;
  String get reviewDurationLabel => _l.guidesReviewDurationLabel;
  String get reviewGroupLabel => _l.guidesReviewGroupLabel;
  String get reviewLanguageLabel => _l.guidesReviewLanguageLabel;
  String get reviewInterestsLabel => _l.guidesReviewInterestsLabel;

  String reviewDurationFormatted(RequestDuration duration, int? hours) {
    switch (duration) {
      case RequestDuration.fewHours:
        return _l.guidesReviewDurationFormattedFewHours;
      case RequestDuration.oneDay:
        return _l.guidesReviewDurationFormattedOneDay;
      case RequestDuration.twoDays:
        return _l.guidesReviewDurationFormattedTwoDays;
      case RequestDuration.threeDays:
        return _l.guidesReviewDurationFormattedThreeDays;
      case RequestDuration.custom:
        return _l.guidesReviewDurationCustom(requestHoursCount(hours ?? 4));
    }
  }

  String formatReviewDate(String yyyyMmDd) {
    final parsed = DateTime.tryParse(yyyyMmDd);
    if (parsed == null) return yyyyMmDd;

    const enDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const arDays = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];

    const enMonths = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const arMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    final weekdayName = isArabic
        ? arDays[parsed.weekday - 1]
        : enDays[parsed.weekday - 1];
    final monthName = isArabic
        ? arMonths[parsed.month - 1]
        : enMonths[parsed.month - 1];
    final dayNum = parsed.day;

    return isArabic
        ? '$weekdayName، $dayNum $monthName'
        : '$weekdayName, $dayNum $monthName';
  }

  String get availabilityNoticeTitle => _l.guidesAvailabilityNoticeTitle;
  String get availabilityNoticeSubtitle => _l.guidesAvailabilityNoticeSubtitle;
  String get confirmAndSendRequest => _l.guidesConfirmAndSendRequest;

  // Request Submitted Screen (P6)
  String get requestSubmittedTitle => _l.guidesRequestSubmittedTitle;
  String get requestSubmittedBody => _l.guidesRequestSubmittedBody;
  String get backToHome => _l.guidesBackToHome;

  // Become a Guide Screen (P7)
  String get guidesApplyTitle => _l.guidesApplyTitle;
  String get applyTitle => guidesApplyTitle;

  String get guidesApplyIntro => _l.guidesApplyIntro;
  String get applyIntro => guidesApplyIntro;

  String get guidesProfilePhoto => _l.guidesProfilePhoto;
  String get profilePhoto => guidesProfilePhoto;

  String get guidesChangePhoto => _l.guidesChangePhoto;
  String get changePhoto => guidesChangePhoto;

  String get guidesRemovePhoto => _l.guidesRemovePhoto;
  String get removePhoto => guidesRemovePhoto;

  String get guidesFullNameLabel => _l.guidesFullNameLabel;
  String get fullNameLabel => guidesFullNameLabel;

  String get guidesFullNameHint => _l.guidesFullNameHint;
  String get fullNameHint => guidesFullNameHint;

  String get guidesLanguagesLabel => _l.guidesLanguagesLabel;
  String get languagesLabel => guidesLanguagesLabel;

  String get guidesLanguagesHint => _l.guidesLanguagesHint;
  String get languagesHint => guidesLanguagesHint;

  String get guidesSpecialtiesLabel => _l.guidesSpecialtiesLabel;
  String get specialtiesLabel => guidesSpecialtiesLabel;

  String get guidesSpecialtiesHint => _l.guidesSpecialtiesHint;
  String get specialtiesHint => guidesSpecialtiesHint;

  String get guidesBioLabel => _l.guidesBioLabel;
  String get bioLabel => guidesBioLabel;

  String get guidesBioHint => _l.guidesBioHint;
  String get bioHint => guidesBioHint;

  String get guidesDurationsLabel => _l.guidesDurationsLabel;
  String get durationsLabel => guidesDurationsLabel;

  String get guidesDurationsHint => _l.guidesDurationsHint;
  String get durationsHint => guidesDurationsHint;

  String get guidesContactLabel => _l.guidesContactLabel;
  String get contactLabel => guidesContactLabel;

  String get guidesContactHint => '+20';
  String get contactHint => guidesContactHint;

  String get guidesSubmitApplication => _l.guidesSubmitApplication;
  String get submitApplication => guidesSubmitApplication;

  // Application Received Screen (P7)
  String get guidesApplicationReceivedTitle =>
      _l.guidesApplicationReceivedTitle;
  String get applicationReceivedTitle => guidesApplicationReceivedTitle;

  String get guidesApplicationReceivedBody => _l.guidesApplicationReceivedBody;
  String get applicationReceivedBody => guidesApplicationReceivedBody;

  String get guidesBackToGuides => _l.guidesBackToGuides;
  String get backToGuides => guidesBackToGuides;

  // Multi-select Bottom Sheet (P7)
  String get guidesSelectLanguages => _l.guidesSelectLanguages;
  String get selectLanguages => guidesSelectLanguages;

  String get guidesSelectSpecialties => _l.guidesSelectSpecialties;
  String get selectSpecialties => guidesSelectSpecialties;

  String get guidesSelectDurations => _l.guidesSelectDurations;
  String get selectDurations => guidesSelectDurations;

  String get guidesDone => _l.guidesDone;
  String get done => guidesDone;

  String get guidesCancel => _l.guidesCancel;
  String get cancel => guidesCancel;

  // Validation & Error Messages (P7)
  String get guidesFieldRequired => _l.guidesFieldRequired;
  String get fieldRequired => guidesFieldRequired;

  String get guidesSelectAtLeastOne => _l.guidesSelectAtLeastOne;
  String get selectAtLeastOne => guidesSelectAtLeastOne;

  String get guidesInvalidPhone => _l.guidesInvalidPhone;
  String get invalidPhone => guidesInvalidPhone;

  String get guidesBioTooShort => _l.guidesBioTooShort;
  String get bioTooShort => guidesBioTooShort;

  String get guidesAlreadyApplied => _l.guidesAlreadyApplied;
  String get alreadyApplied => guidesAlreadyApplied;

  String get guidesFileTooLarge => _l.guidesFileTooLarge;
  String get fileTooLarge => guidesFileTooLarge;

  String get guidesUnsupportedFileType => _l.guidesUnsupportedFileType;
  String get unsupportedFileType => guidesUnsupportedFileType;

  String get guidesGeneralValidationError => _l.guidesGeneralValidationError;
  String get generalValidationError => guidesGeneralValidationError;
}

extension LocalGuidesStringsX on BuildContext {
  LocalGuidesStrings get guidesL10n => LocalGuidesStrings.of(this);
}
