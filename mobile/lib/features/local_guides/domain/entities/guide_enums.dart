library;

/// Allowed enums for local guides, requests, and applications per API Contract v0.2.

enum GuideDuration {
  fewHours('few_hours'),
  oneDay('one_day'),
  multipleDays('multiple_days');

  const GuideDuration(this.value);
  final String value;

  static GuideDuration fromValue(String value) =>
      GuideDuration.values.firstWhere(
        (e) => e.value == value,
        orElse: () => GuideDuration.fewHours,
      );
}

enum RequestDuration {
  fewHours('few_hours'),
  oneDay('one_day'),
  twoDays('two_days'),
  threeDays('three_days'),
  custom('custom');

  const RequestDuration(this.value);
  final String value;

  static RequestDuration fromValue(String value) =>
      RequestDuration.values.firstWhere(
        (e) => e.value == value,
        orElse: () => RequestDuration.fewHours,
      );
}

enum GuideSpecialty {
  nubianCulture('nubian_culture'),
  historicalSites('historical_sites'),
  nile('nile'),
  photography('photography'),
  localExperiences('local_experiences');

  const GuideSpecialty(this.value);
  final String value;

  static GuideSpecialty fromValue(String value) =>
      GuideSpecialty.values.firstWhere(
        (e) => e.value == value,
        orElse: () => GuideSpecialty.nubianCulture,
      );
}

enum GuideLanguage {
  ar('ar'),
  en('en'),
  fr('fr'),
  de('de'),
  it('it'),
  es('es');

  const GuideLanguage(this.value);
  final String value;

  static GuideLanguage fromValue(String value) =>
      GuideLanguage.values.firstWhere(
        (e) => e.value == value,
        orElse: () => GuideLanguage.ar,
      );
}

enum RequestStatus {
  pending('pending'),
  accepted('accepted'),
  rejected('rejected');

  const RequestStatus(this.value);
  final String value;

  static RequestStatus fromValue(String value) =>
      RequestStatus.values.firstWhere(
        (e) => e.value == value,
        orElse: () => RequestStatus.pending,
      );
}
