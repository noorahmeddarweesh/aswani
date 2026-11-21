/// Guide DTO exactly matching API Contract v0.2.
/// Fields: id, full_name, photo (URL|null), city, tagline, languages[],
/// specialties[], bio, durations[], is_featured, is_verified.
class GuideDto {
  const GuideDto({
    required this.id,
    required this.fullName,
    this.photo,
    required this.city,
    required this.tagline,
    required this.languages,
    required this.specialties,
    required this.bio,
    required this.durations,
    required this.isFeatured,
    required this.isVerified,
  });

  factory GuideDto.fromJson(Map<String, dynamic> json) => GuideDto(
    id: json['id'] as String,
    fullName: json['full_name'] as String,
    photo: json['photo'] as String?,
    city: json['city'] as String,
    tagline: json['tagline'] as String,
    languages: (json['languages'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [],
    specialties: (json['specialties'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [],
    bio: json['bio'] as String,
    durations: (json['durations'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [],
    isFeatured: json['is_featured'] as bool? ?? false,
    isVerified: json['is_verified'] as bool? ?? false,
  );

  final String id;
  final String fullName;
  final String? photo;
  final String city;
  final String tagline;
  final List<String> languages;
  final List<String> specialties;
  final String bio;
  final List<String> durations;
  final bool isFeatured;
  final bool isVerified;

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'photo': photo,
    'city': city,
    'tagline': tagline,
    'languages': languages,
    'specialties': specialties,
    'bio': bio,
    'durations': durations,
    'is_featured': isFeatured,
    'is_verified': isVerified,
  };
}

/// Minimal guide summary DTO in guide requests.
class GuideSummaryDto {
  const GuideSummaryDto({
    required this.id,
    required this.fullName,
    this.photo,
  });

  factory GuideSummaryDto.fromJson(Map<String, dynamic> json) => GuideSummaryDto(
    id: json['id'] as String,
    fullName: json['full_name'] as String,
    photo: json['photo'] as String?,
  );

  final String id;
  final String fullName;
  final String? photo;

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'photo': photo,
  };
}
