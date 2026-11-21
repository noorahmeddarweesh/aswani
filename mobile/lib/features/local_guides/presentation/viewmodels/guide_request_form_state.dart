import '../../domain/entities/guide_enums.dart';
import '../../domain/entities/guide_request.dart';

/// Calculates current Cairo local DateTime from a given UTC DateTime.
/// Accounts for Egypt's DST (Law No. 24 of 2023: UTC+3 from the last Friday
/// of April to the last Thursday of October; UTC+2 otherwise).
DateTime getCairoDateTime([DateTime? utcNow]) {
  final utc = (utcNow ?? DateTime.now()).toUtc();
  final year = utc.year;

  // Determine last Friday of April (April has 30 days)
  final apr30 = DateTime.utc(year, 4, 30);
  final daysBackToFridayInApr = (apr30.weekday - DateTime.friday + 7) % 7;
  final lastFridayAprDay = 30 - daysBackToFridayInApr;
  // DST begins on last Friday of April at 00:00 Cairo time (22:00 UTC previous day)
  final dstStartUtc = DateTime.utc(year, 4, lastFridayAprDay - 1, 22, 0);

  // Determine last Thursday of October (October has 31 days)
  final oct31 = DateTime.utc(year, 10, 31);
  final daysBackToThursdayInOct = (oct31.weekday - DateTime.thursday + 7) % 7;
  final lastThursdayOctDay = 31 - daysBackToThursdayInOct;
  // DST ends on last Thursday of October at 24:00 Cairo time (21:00 UTC on Thursday)
  final dstEndUtc = DateTime.utc(year, 10, lastThursdayOctDay, 21, 0);

  final isDst = utc.isAfter(dstStartUtc) && utc.isBefore(dstEndUtc);
  final offsetHours = isDst ? 3 : 2;
  return utc.add(Duration(hours: offsetHours));
}

/// Returns the current calendar date in Africa/Cairo formatted as 'YYYY-MM-DD'.
String getCairoTodayDateString([DateTime? utcNow]) {
  final cairo = getCairoDateTime(utcNow);
  final y = cairo.year.toString().padLeft(4, '0');
  final m = cairo.month.toString().padLeft(2, '0');
  final d = cairo.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Validates whether a YYYY-MM-DD date is today or in the future in Cairo time.
/// Returns true if valid, false if in the past.
bool isCairoDateTodayOrFuture(String dateStr, [DateTime? utcNow]) {
  final todayStr = getCairoTodayDateString(utcNow);
  return dateStr.compareTo(todayStr) >= 0;
}

/// Form state for requesting a guide per API Contract v0.2 and design_spec.txt.
class GuideRequestFormState {
  const GuideRequestFormState({
    required this.guideId,
    this.date,
    this.duration = RequestDuration.oneDay,
    this.durationHours = 6,
    this.startTime = '09:00',
    this.groupSize = 2,
    this.language = GuideLanguage.en,
    this.interests = const [],
    this.notes,
    this.dateError,
    this.customHoursError,
    this.isSubmitting = false,
  });

  final String guideId;
  final String? date;
  final RequestDuration duration;
  final int? durationHours;
  final String startTime;
  final int groupSize;
  final GuideLanguage language;
  final List<GuideSpecialty> interests;
  final String? notes;
  final String? dateError;
  final String? customHoursError;
  final bool isSubmitting;

  bool get isValid =>
      date != null &&
      date!.trim().isNotEmpty &&
      dateError == null &&
      customHoursError == null;

  GuideRequestFormState copyWith({
    String? guideId,
    String? date,
    bool clearDate = false,
    RequestDuration? duration,
    int? durationHours,
    bool clearDurationHours = false,
    String? startTime,
    int? groupSize,
    GuideLanguage? language,
    List<GuideSpecialty>? interests,
    String? notes,
    bool clearNotes = false,
    String? dateError,
    bool clearDateError = false,
    String? customHoursError,
    bool clearCustomHoursError = false,
    bool? isSubmitting,
  }) {
    return GuideRequestFormState(
      guideId: guideId ?? this.guideId,
      date: clearDate ? null : (date ?? this.date),
      duration: duration ?? this.duration,
      durationHours: clearDurationHours
          ? null
          : (durationHours ?? this.durationHours),
      startTime: startTime ?? this.startTime,
      groupSize: groupSize ?? this.groupSize,
      language: language ?? this.language,
      interests: interests ?? this.interests,
      notes: clearNotes ? null : (notes ?? this.notes),
      dateError: clearDateError ? null : (dateError ?? this.dateError),
      customHoursError: clearCustomHoursError
          ? null
          : (customHoursError ?? this.customHoursError),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  /// Converts this form state into the final [GuideRequestCreate] payload.
  /// Enforces duration mapping rules:
  /// - `custom`: requires [durationHours] (1..12).
  /// - `one_day`: maps to 6 hours.
  /// - `few_hours`, `two_days`, `three_days`: omits [durationHours] (null).
  GuideRequestCreate toCreatePayload() {
    int? computedHours;
    if (duration == RequestDuration.custom) {
      computedHours = durationHours;
    } else if (duration == RequestDuration.oneDay) {
      computedHours = 6;
    } else {
      computedHours = null;
    }

    final trimmedNotes = notes?.trim();

    return GuideRequestCreate(
      guideId: guideId,
      date: date!,
      duration: duration,
      durationHours: computedHours,
      startTime: startTime,
      groupSize: groupSize,
      language: language,
      interests: interests,
      notes: (trimmedNotes != null && trimmedNotes.isNotEmpty)
          ? trimmedNotes
          : null,
    );
  }
}
