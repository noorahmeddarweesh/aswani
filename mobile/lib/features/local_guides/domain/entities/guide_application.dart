import 'guide_enums.dart';

import '../../../../core/network/upload.dart';

/// Form entity for applying to become a local guide.
class GuideApplicationCreate {
  const GuideApplicationCreate({
    required this.fullName,
    required this.languages,
    required this.specialties,
    required this.bio,
    required this.durations,
    required this.contact,
    this.profilePhoto,
  });

  final String fullName;
  final List<GuideLanguage> languages;
  final List<GuideSpecialty> specialties;
  final String bio;
  final List<GuideDuration> durations;
  final String contact;
  final UploadFile? profilePhoto;
}

/// Result returned after submitting a guide application.
class GuideApplicationResult {
  const GuideApplicationResult({required this.id, required this.status});

  final String id;
  final RequestStatus status;
}
