/// DTO for POST /api/guide-applications multipart form.
/// Fields: full_name, languages[], specialties[], bio, durations[], contact, profile_photo?.
class GuideApplicationCreateDto {
  const GuideApplicationCreateDto({
    required this.fullName,
    required this.languages,
    required this.specialties,
    required this.bio,
    required this.durations,
    required this.contact,
    this.profilePhoto,
  });

  factory GuideApplicationCreateDto.fromJson(Map<String, dynamic> json) =>
      GuideApplicationCreateDto(
        fullName: json['full_name'] as String,
        languages:
            (json['languages'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        specialties:
            (json['specialties'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        bio: json['bio'] as String,
        durations:
            (json['durations'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        contact: json['contact'] as String,
        profilePhoto: json['profile_photo'] as String?,
      );

  final String fullName;
  final List<String> languages;
  final List<String> specialties;
  final String bio;
  final List<String> durations;
  final String contact;
  final String? profilePhoto;

  Map<String, dynamic> toJson() => {
    'full_name': fullName,
    'languages': languages,
    'specialties': specialties,
    'bio': bio,
    'durations': durations,
    'contact': contact,
    if (profilePhoto != null) 'profile_photo': profilePhoto,
  };
}

/// DTO for POST /api/guide-applications response: { "id", "status": "pending" }.
class GuideApplicationResultDto {
  const GuideApplicationResultDto({required this.id, required this.status});

  factory GuideApplicationResultDto.fromJson(Map<String, dynamic> json) =>
      GuideApplicationResultDto(
        id: json['id'] as String,
        status: json['status'] as String? ?? 'pending',
      );

  final String id;
  final String status;

  Map<String, dynamic> toJson() => {'id': id, 'status': status};
}
