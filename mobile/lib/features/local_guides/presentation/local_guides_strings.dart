import 'package:aswani/features/local_guides/domain/entities/guide_enums.dart';
import 'package:material_ui/material_ui.dart';

/// Localized strings for the Local Guides feature.
/// Provides English and Arabic copy matching tour_guides.jpg and design_spec.txt
/// without modifying core ARB files during Phase 1.
class LocalGuidesStrings {
  const LocalGuidesStrings._({required this.isArabic});

  final bool isArabic;

  static LocalGuidesStrings of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isArabic =
        locale.languageCode == 'ar' ||
        Directionality.of(context) == TextDirection.rtl;
    return LocalGuidesStrings._(isArabic: isArabic);
  }

  // Screen header
  String get eyebrow => isArabic ? 'معرفة محلية' : 'LOCAL KNOWLEDGE';
  String get title => isArabic
      ? 'استكشف أسوان مع مرشد محلي'
      : 'Explore Aswan with a local guide';
  String get subtitle => isArabic
      ? 'اعثر على من يعرف قصصها وثقافتها وأماكنها الخفية.'
      : 'Find someone who knows its stories, culture, and hidden places.';

  // Search
  String get searchHint =>
      isArabic ? 'ابحث بالاسم أو التخصص' : 'Search by name or specialty';

  // Specialty chips
  String get filterAll => isArabic ? 'الكل' : 'All';
  String specialtyLabel(GuideSpecialty specialty) {
    switch (specialty) {
      case GuideSpecialty.nubianCulture:
        return isArabic ? 'ثقافة نوبية' : 'Nubian culture';
      case GuideSpecialty.historicalSites:
        return isArabic ? 'مواقع تاريخية' : 'Historical sites';
      case GuideSpecialty.nile:
        return isArabic ? 'النيل' : 'Nile';
      case GuideSpecialty.photography:
        return isArabic ? 'تصوير' : 'Photography';
      case GuideSpecialty.localExperiences:
        return isArabic ? 'تجارب محلية' : 'Local experiences';
    }
  }

  // Featured guide card
  String get sampleProfile => isArabic ? 'ملف تجريبي' : 'SAMPLE PROFILE';
  String durationLabel(GuideDuration duration) {
    switch (duration) {
      case GuideDuration.fewHours:
        return isArabic ? 'بضع ساعات' : 'Few hours';
      case GuideDuration.oneDay:
        return isArabic ? 'يوم كامل' : 'Full day';
      case GuideDuration.multipleDays:
        return isArabic ? 'عدة أيام' : 'Multiple days';
    }
  }

  // Suggested guides section
  String get suggestedSectionTitle =>
      isArabic ? 'مرشدون مقترحون' : 'Suggested guides';
  String get filterAction => isArabic ? 'تصفية ←' : 'Filter →';
  String get illustrativeNote =>
      isArabic ? 'معلومات توضيحية' : 'Illustrative information';

  // CTA Card
  String get ctaTitle =>
      isArabic ? 'تعرف أسوان عن ظهر قلب؟' : 'Know Aswan by heart?';
  String get ctaSubtitle =>
      isArabic ? 'قدّم لتقديم خدمات الإرشاد' : 'Apply to offer guide services';

  // States
  String get emptySearch => isArabic
      ? 'لا يوجد مرشدون يطابقون بحثك.'
      : 'No guides match your search.';
  String get emptyFilter => isArabic
      ? 'لا يوجد مرشدون متاحون لهذا التخصص.'
      : 'No guides available for this specialty.';
  String get errorLoading => isArabic
      ? 'تعذر تحميل المرشدين. يُرجى المحاولة مرة أخرى.'
      : 'Failed to load guides. Please try again.';
  String get retry => isArabic ? 'حاول مرة أخرى' : 'Try again';

  // Guide Details Screen (P4)
  String get guidesSampleProfileNotVerified =>
      isArabic ? 'ملف تجريبي • غير موثق' : 'SAMPLE PROFILE • NOT VERIFIED';
  String get sampleProfileNotVerified => guidesSampleProfileNotVerified;

  String get guidesSpecialties => isArabic ? 'التخصصات' : 'Specialties';
  String get specialtiesHeader => guidesSpecialties;

  String get guidesAvailableTourDurations =>
      isArabic ? 'مدد الجولات المتاحة' : 'Available tour durations';
  String get availableDurationsHeader => guidesAvailableTourDurations;

  String get guidesNoticeTitle => isArabic
      ? 'طلب إرشاد، وليس حجزًا مؤكدًا'
      : 'A request, not a confirmed booking';
  String get noticeTitle => guidesNoticeTitle;

  String get guidesNoticeSubtitle => isArabic
      ? 'يقوم المرشد بمراجعة التفاصيل قبل تأكيد أي موعد.'
      : 'The guide reviews details before any time is confirmed.';
  String get noticeSubtitle => guidesNoticeSubtitle;

  String get guidesRequestThisGuide =>
      isArabic ? 'طلب هذا المرشد' : 'Request this guide';
  String get requestThisGuide => guidesRequestThisGuide;

  String get guidesNotFound =>
      isArabic ? 'لم يتم العثور على المرشد.' : 'Guide not found.';
  String get guideNotFound => guidesNotFound;

  String get guidesBack => isArabic ? 'رجوع' : 'Back';
  String get back => guidesBack;

  String get guidesShare => isArabic ? 'مشاركة' : 'Share';
  String get share => guidesShare;

  String languageLabel(GuideLanguage language) {
    switch (language) {
      case GuideLanguage.ar:
        return isArabic ? 'العربية' : 'Arabic';
      case GuideLanguage.en:
        return isArabic ? 'الإنجليزية' : 'English';
      case GuideLanguage.fr:
        return isArabic ? 'الفرنسية' : 'French';
      case GuideLanguage.de:
        return isArabic ? 'الألمانية' : 'German';
      case GuideLanguage.it:
        return isArabic ? 'الإيطالية' : 'Italian';
      case GuideLanguage.es:
        return isArabic ? 'الإسبانية' : 'Spanish';
    }
  }

  String languagesFormatted(List<GuideLanguage> languages) {
    return languages.map(languageLabel).join(isArabic ? ' و ' : ' & ');
  }

  String detailsSpecialtyLabel(GuideSpecialty specialty) {
    if (specialty == GuideSpecialty.historicalSites) {
      return isArabic ? 'جولات تاريخية' : 'Historical walks';
    }
    return specialtyLabel(specialty);
  }

  String detailsDurationLabel(GuideDuration duration) {
    switch (duration) {
      case GuideDuration.fewHours:
        return isArabic ? 'بضع ساعات' : 'Few hours';
      case GuideDuration.oneDay:
        return isArabic ? 'يوم واحد' : 'One day';
      case GuideDuration.multipleDays:
        return isArabic ? 'عدة أيام' : 'Multiple days';
    }
  }

  // Request a Guide Form (P5)
  String get requestScreenTitle => isArabic ? 'طلب مرشد' : 'Request a guide';
  String get requestIntro => isArabic
      ? 'أخبرنا بما يناسب خططك. اختر المدة التي تحتاجها بدقة.'
      : 'Tell us what fits your plans. Choose exactly how long you need.';
  String get requestPreferredDate =>
      isArabic ? 'التاريخ المفضل' : 'Preferred date';
  String get requestSelectDate => isArabic ? 'اختر التاريخ' : 'Select date';
  String get requestTourDuration => isArabic ? 'مدة الجولة' : 'Tour duration';

  String requestDurationLabel(RequestDuration duration) {
    switch (duration) {
      case RequestDuration.fewHours:
        return isArabic ? 'بضع ساعات' : 'A few hours';
      case RequestDuration.oneDay:
        return isArabic ? 'يوم واحد' : 'One day';
      case RequestDuration.twoDays:
        return isArabic ? 'يومان' : 'Two days';
      case RequestDuration.threeDays:
        return isArabic ? '3 أيام' : '3 days';
      case RequestDuration.custom:
        return isArabic ? 'مخصص' : 'Custom';
    }
  }

  String get requestStartTime => isArabic ? 'وقت البدء' : 'Start time';
  String get requestGroupSize => isArabic ? 'حجم المجموعة' : 'Group size';
  String requestGroupSizeFormatted(int count) {
    if (isArabic) {
      if (count == 1) return 'شخص واحد';
      if (count == 2) return 'شخصان';
      if (count >= 3 && count <= 10) return '$count أشخاص';
      return '$count شخص';
    }
    return count == 1 ? '1 person' : '$count people';
  }

  String get requestPreferredLanguage =>
      isArabic ? 'اللغة المفضلة' : 'Preferred language';
  String get requestAdditionalNotes =>
      isArabic ? 'ملاحظات إضافية (اختياري)' : 'Additional notes (optional)';
  String get requestNotesHint => isArabic
      ? 'أخبر المرشد بما يهمك...'
      : 'Tell the guide what matters to you...';
  String get requestReviewButton =>
      isArabic ? 'مراجعة الطلب' : 'Review request';

  // Validation & Helpers
  String get requestDateRequired =>
      isArabic ? 'التاريخ مطلوب' : 'Date is required';
  String get requestDateInPast => isArabic
      ? 'لا يمكن أن يكون التاريخ في الماضي'
      : 'Date cannot be in the past';
  String get requestCustomHoursRequired => isArabic
      ? 'يجب أن تكون الساعات بين 1 و 12'
      : 'Custom duration must be between 1 and 12 hours';
  String get requestCustomDurationLabel =>
      isArabic ? 'عدد الساعات' : 'Custom hours';
  String requestHoursCount(int hours) {
    if (isArabic) {
      if (hours == 1) return 'ساعة واحدة';
      if (hours == 2) return 'ساعتان';
      if (hours >= 3 && hours <= 10) return '$hours ساعات';
      return '$hours ساعة';
    }
    return hours == 1 ? '1 hour' : '$hours hours';
  }

  // Review Request Screen (P6)
  String get reviewScreenTitle => isArabic ? 'مراجعة الطلب' : 'Review request';
  String get selectedGuideEyebrow =>
      isArabic ? 'المرشد المحدد' : 'SELECTED GUIDE';
  String get reviewSampleProfile => isArabic ? 'ملف تجريبي' : 'Sample profile';
  String get reviewDateLabel => isArabic ? 'التاريخ' : 'Date';
  String get reviewDurationLabel => isArabic ? 'المدة' : 'Duration';
  String get reviewGroupLabel => isArabic ? 'المجموعة' : 'Group';
  String get reviewLanguageLabel => isArabic ? 'اللغة' : 'Language';
  String get reviewInterestsLabel => isArabic ? 'الاهتمامات' : 'Interests';

  String reviewDurationFormatted(RequestDuration duration, int? hours) {
    switch (duration) {
      case RequestDuration.fewHours:
        return isArabic ? 'بضع ساعات' : 'A few hours';
      case RequestDuration.oneDay:
        return isArabic ? 'يوم واحد • 6 ساعات' : 'One day • 6 hours';
      case RequestDuration.twoDays:
        return isArabic ? 'يومان' : 'Two days';
      case RequestDuration.threeDays:
        return isArabic ? '3 أيام' : '3 days';
      case RequestDuration.custom:
        final h = hours ?? 4;
        return isArabic
            ? 'مخصص • ${requestHoursCount(h)}'
            : 'Custom • $h hours';
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

  String get availabilityNoticeTitle =>
      isArabic ? 'التوفر غير مضمون' : 'Availability is not guaranteed';
  String get availabilityNoticeSubtitle => isArabic
      ? 'يتم تأكيد الموعد فقط بعد موافقة المرشد.'
      : 'The date is confirmed only after the guide accepts.';
  String get confirmAndSendRequest =>
      isArabic ? 'تأكيد وإرسال الطلب' : 'Confirm and send request';

  // Request Submitted Screen (P6)
  String get requestSubmittedTitle =>
      isArabic ? 'تم إرسال الطلب' : 'Request submitted';
  String get requestSubmittedBody => isArabic
      ? 'طلبك قيد المراجعة. ليس حجزًا مؤكدًا بعد؛ سنخطرك عندما يرد المرشد.'
      : "Your request is under review. It is not a confirmed booking yet; we'll notify you when the guide responds.";
  String get backToHome => isArabic ? 'العودة للرئيسية' : 'Back to home';

  // Become a Guide Screen (P7)
  String get guidesApplyTitle => isArabic ? 'كن مرشدًا' : 'Become a guide';
  String get applyTitle => guidesApplyTitle;

  String get guidesApplyIntro => isArabic
      ? 'أظهر للزوار أسوان من منظورك المحلي. تتم مراجعة التفاصيل قبل النشر.'
      : 'Show visitors Aswan through your local perspective. Details are reviewed before publication.';
  String get applyIntro => guidesApplyIntro;

  String get guidesProfilePhoto =>
      isArabic ? 'صورة الملف الشخصي' : 'Profile photo';
  String get profilePhoto => guidesProfilePhoto;

  String get guidesChangePhoto => isArabic ? 'تغيير الصورة' : 'Change photo';
  String get changePhoto => guidesChangePhoto;

  String get guidesRemovePhoto => isArabic ? 'إزالة الصورة' : 'Remove photo';
  String get removePhoto => guidesRemovePhoto;

  String get guidesFullNameLabel => isArabic ? 'الاسم الكامل *' : 'Full name *';
  String get fullNameLabel => guidesFullNameLabel;

  String get guidesFullNameHint =>
      isArabic ? 'الاسم الظاهر للزوار' : 'Name shown to visitors';
  String get fullNameHint => guidesFullNameHint;

  String get guidesLanguagesLabel => isArabic ? 'اللغات *' : 'Languages *';
  String get languagesLabel => guidesLanguagesLabel;

  String get guidesLanguagesHint =>
      isArabic ? 'العربية، الإنجليزية' : 'Arabic, English';
  String get languagesHint => guidesLanguagesHint;

  String get guidesSpecialtiesLabel =>
      isArabic ? 'تخصصات الجولات *' : 'Tour specialties *';
  String get specialtiesLabel => guidesSpecialtiesLabel;

  String get guidesSpecialtiesHint =>
      isArabic ? 'ثقافة نوبية، النيل...' : 'Nubian culture, Nile...';
  String get specialtiesHint => guidesSpecialtiesHint;

  String get guidesBioLabel =>
      isArabic ? 'نبذة شخصية قصيرة *' : 'Short biography *';
  String get bioLabel => guidesBioLabel;

  String get guidesBioHint => isArabic
      ? 'شارك خبراتك واهتماماتك...'
      : 'Share your experience and interests...';
  String get bioHint => guidesBioHint;

  String get guidesDurationsLabel =>
      isArabic ? 'المدد المتاحة' : 'Available durations';
  String get durationsLabel => guidesDurationsLabel;

  String get guidesDurationsHint =>
      isArabic ? 'بضع ساعات، يوم كامل' : 'Few hours, full day';
  String get durationsHint => guidesDurationsHint;

  String get guidesContactLabel =>
      isArabic ? 'بيانات التواصل *' : 'Contact details *';
  String get contactLabel => guidesContactLabel;

  String get guidesContactHint => '+20';
  String get contactHint => guidesContactHint;

  String get guidesSubmitApplication =>
      isArabic ? 'إرسال الطلب' : 'Submit application';
  String get submitApplication => guidesSubmitApplication;

  // Application Received Screen (P7)
  String get guidesApplicationReceivedTitle =>
      isArabic ? 'تم استلام الطلب' : 'Application received';
  String get applicationReceivedTitle => guidesApplicationReceivedTitle;

  String get guidesApplicationReceivedBody => isArabic
      ? 'سنراجع المعلومات ونتواصل معك. لا يعني التقديم اعتمادًا أو توثيقًا رسميًا.'
      : "We'll review the information and contact you. Submission does not indicate official verification or certification.";
  String get applicationReceivedBody => guidesApplicationReceivedBody;

  String get guidesBackToGuides =>
      isArabic ? 'العودة للمرشدين' : 'Back to guides';
  String get backToGuides => guidesBackToGuides;

  // Multi-select Bottom Sheet (P7)
  String get guidesSelectLanguages =>
      isArabic ? 'تحديد اللغات' : 'Select languages';
  String get selectLanguages => guidesSelectLanguages;

  String get guidesSelectSpecialties =>
      isArabic ? 'تحديد تخصصات الجولات' : 'Select tour specialties';
  String get selectSpecialties => guidesSelectSpecialties;

  String get guidesSelectDurations =>
      isArabic ? 'تحديد مدد الجولات' : 'Select available durations';
  String get selectDurations => guidesSelectDurations;

  String get guidesDone => isArabic ? 'تم' : 'Done';
  String get done => guidesDone;

  String get guidesCancel => isArabic ? 'إلغاء' : 'Cancel';
  String get cancel => guidesCancel;

  // Validation & Error Messages (P7)
  String get guidesFieldRequired =>
      isArabic ? 'هذا الحقل مطلوب' : 'This field is required';
  String get fieldRequired => guidesFieldRequired;

  String get guidesSelectAtLeastOne => isArabic
      ? 'يرجى اختيار خيار واحد على الأقل'
      : 'Please select at least one option';
  String get selectAtLeastOne => guidesSelectAtLeastOne;

  String get guidesInvalidPhone => isArabic
      ? 'أدخل رقم هاتف مصري صحيح (مثال: 010xxxxxxxx)'
      : 'Enter a valid Egyptian mobile number (e.g. 010xxxxxxxx)';
  String get invalidPhone => guidesInvalidPhone;

  String get guidesBioTooShort => isArabic
      ? 'يجب ألا تقل النبذة عن 10 أحرف'
      : 'Biography must be at least 10 characters';
  String get bioTooShort => guidesBioTooShort;

  String get guidesAlreadyApplied => isArabic
      ? 'يوجد بالفعل طلب مقدم بهذا الرقم.'
      : 'An application with this mobile number already exists.';
  String get alreadyApplied => guidesAlreadyApplied;

  String get guidesFileTooLarge => isArabic
      ? 'يجب أن يكون حجم الصورة أقل من 5 ميجابايت.'
      : 'Profile photo must be less than 5 MB.';
  String get fileTooLarge => guidesFileTooLarge;

  String get guidesUnsupportedFileType => isArabic
      ? 'التنسيقات المدعومة هي JPG و PNG و WEBP فقط.'
      : 'Only JPG, PNG, and WEBP formats are supported.';
  String get unsupportedFileType => guidesUnsupportedFileType;

  String get guidesGeneralValidationError => isArabic
      ? 'يرجى تصحيح الأخطاء الموضحة.'
      : 'Please correct the highlighted errors.';
  String get generalValidationError => guidesGeneralValidationError;
}

extension LocalGuidesStringsX on BuildContext {
  LocalGuidesStrings get guidesL10n => LocalGuidesStrings.of(this);
}
