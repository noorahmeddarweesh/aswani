import 'guide_enums.dart';

/// Clean domain entity representing a local guide.
class Guide {
  const Guide({
    required this.id,
    required this.fullName,
    required this.photo,
    required this.city,
    required this.tagline,
    required this.languages,
    required this.specialties,
    required this.bio,
    required this.durations,
    required this.isFeatured,
    required this.isVerified,
  });

  final String id;
  final String fullName;
  final String? photo;
  final String city;
  final String tagline;
  final List<GuideLanguage> languages;
  final List<GuideSpecialty> specialties;
  final String bio;
  final List<GuideDuration> durations;
  final bool isFeatured;
  final bool isVerified;
}

/// Minimal summary of a guide used in request items.
class GuideSummary {
  const GuideSummary({
    required this.id,
    required this.fullName,
    this.photo,
  });

  final String id;
  final String fullName;
  final String? photo;
}
