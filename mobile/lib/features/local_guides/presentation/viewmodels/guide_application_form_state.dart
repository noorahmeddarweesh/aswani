import '../../domain/entities/guide_application.dart';
import '../../domain/entities/guide_enums.dart';

/// Immutable form state for the Become a Guide application form.
class GuideApplicationFormState {
  const GuideApplicationFormState({
    this.fullName = '',
    this.languages = const [],
    this.specialties = const [],
    this.bio = '',
    this.durations = const [],
    this.contact = '',
    this.profilePhoto,
    this.fullNameError,
    this.languagesError,
    this.specialtiesError,
    this.bioError,
    this.durationsError,
    this.contactError,
    this.photoError,
    this.isSubmitting = false,
    this.serverError,
  });

  final String fullName;
  final List<GuideLanguage> languages;
  final List<GuideSpecialty> specialties;
  final String bio;
  final List<GuideDuration> durations;
  final String contact;
  final String? profilePhoto;

  final String? fullNameError;
  final String? languagesError;
  final String? specialtiesError;
  final String? bioError;
  final String? durationsError;
  final String? contactError;
  final String? photoError;

  final bool isSubmitting;
  final String? serverError;

  bool get hasFieldErrors =>
      fullNameError != null ||
      languagesError != null ||
      specialtiesError != null ||
      bioError != null ||
      durationsError != null ||
      contactError != null ||
      photoError != null;

  GuideApplicationCreate toEntity() => GuideApplicationCreate(
        fullName: fullName.trim(),
        languages: languages,
        specialties: specialties,
        bio: bio.trim(),
        durations: durations,
        contact: contact.trim(),
        profilePhoto: profilePhoto,
      );

  GuideApplicationFormState copyWith({
    String? fullName,
    List<GuideLanguage>? languages,
    List<GuideSpecialty>? specialties,
    String? bio,
    List<GuideDuration>? durations,
    String? contact,
    String? Function()? profilePhoto,
    String? Function()? fullNameError,
    String? Function()? languagesError,
    String? Function()? specialtiesError,
    String? Function()? bioError,
    String? Function()? durationsError,
    String? Function()? contactError,
    String? Function()? photoError,
    bool? isSubmitting,
    String? Function()? serverError,
  }) {
    return GuideApplicationFormState(
      fullName: fullName ?? this.fullName,
      languages: languages ?? this.languages,
      specialties: specialties ?? this.specialties,
      bio: bio ?? this.bio,
      durations: durations ?? this.durations,
      contact: contact ?? this.contact,
      profilePhoto:
          profilePhoto != null ? profilePhoto() : this.profilePhoto,
      fullNameError:
          fullNameError != null ? fullNameError() : this.fullNameError,
      languagesError:
          languagesError != null ? languagesError() : this.languagesError,
      specialtiesError:
          specialtiesError != null ? specialtiesError() : this.specialtiesError,
      bioError: bioError != null ? bioError() : this.bioError,
      durationsError:
          durationsError != null ? durationsError() : this.durationsError,
      contactError:
          contactError != null ? contactError() : this.contactError,
      photoError: photoError != null ? photoError() : this.photoError,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      serverError: serverError != null ? serverError() : this.serverError,
    );
  }
}
