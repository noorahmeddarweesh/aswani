import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/guide_application.dart';
import '../../domain/entities/guide_enums.dart';
import '../../local_guides_providers.dart';
import 'guide_application_form_state.dart';

/// Riverpod provider for GuideApplicationViewModel.
final guideApplicationViewModelProvider =
    NotifierProvider.autoDispose<
      GuideApplicationViewModel,
      GuideApplicationFormState
    >(GuideApplicationViewModel.new);

class GuideApplicationViewModel extends Notifier<GuideApplicationFormState> {
  static final RegExp _egyptPhone = RegExp(r'^(\+20|0020|0)?1[0125]\d{8}$');

  @override
  GuideApplicationFormState build() => const GuideApplicationFormState();

  void setFullName(String value) {
    state = state.copyWith(
      fullName: value,
      fullNameError: () => null,
      serverError: () => null,
    );
  }

  void setLanguages(List<GuideLanguage> languages) {
    state = state.copyWith(
      languages: languages,
      languagesError: () => null,
      serverError: () => null,
    );
  }

  void toggleLanguage(GuideLanguage language) {
    final current = List<GuideLanguage>.from(state.languages);
    if (current.contains(language)) {
      current.remove(language);
    } else {
      current.add(language);
    }
    setLanguages(current);
  }

  void setSpecialties(List<GuideSpecialty> specialties) {
    state = state.copyWith(
      specialties: specialties,
      specialtiesError: () => null,
      serverError: () => null,
    );
  }

  void toggleSpecialty(GuideSpecialty specialty) {
    final current = List<GuideSpecialty>.from(state.specialties);
    if (current.contains(specialty)) {
      current.remove(specialty);
    } else {
      current.add(specialty);
    }
    setSpecialties(current);
  }

  void setBio(String value) {
    state = state.copyWith(
      bio: value,
      bioError: () => null,
      serverError: () => null,
    );
  }

  void setDurations(List<GuideDuration> durations) {
    state = state.copyWith(
      durations: durations,
      durationsError: () => null,
      serverError: () => null,
    );
  }

  void toggleDuration(GuideDuration duration) {
    final current = List<GuideDuration>.from(state.durations);
    if (current.contains(duration)) {
      current.remove(duration);
    } else {
      current.add(duration);
    }
    setDurations(current);
  }

  void setContact(String value) {
    state = state.copyWith(
      contact: value,
      contactError: () => null,
      serverError: () => null,
    );
  }

  void setProfilePhoto(String? path) {
    String? photoError;
    if (path != null && path.isNotEmpty) {
      final lower = path.toLowerCase();
      final hasValidExt =
          lower.endsWith('.jpg') ||
          lower.endsWith('.jpeg') ||
          lower.endsWith('.png') ||
          lower.endsWith('.webp');

      if (!hasValidExt) {
        photoError = 'UNSUPPORTED_FILE_TYPE';
      } else if (lower.contains('too_large') ||
          lower.contains('file_too_large')) {
        photoError = 'FILE_TOO_LARGE';
      }
    }

    state = state.copyWith(
      profilePhoto: () => path,
      photoError: () => photoError,
      serverError: () => null,
    );
  }

  void clearErrors() {
    state = state.copyWith(
      fullNameError: () => null,
      languagesError: () => null,
      specialtiesError: () => null,
      bioError: () => null,
      durationsError: () => null,
      contactError: () => null,
      photoError: () => null,
      serverError: () => null,
    );
  }

  bool validate() {
    String? fullNameError;
    String? languagesError;
    String? specialtiesError;
    String? bioError;
    String? contactError;

    // Full name validation
    if (state.fullName.trim().isEmpty) {
      fullNameError = 'REQUIRED';
    } else if (state.fullName.trim().length < 2) {
      fullNameError = 'TOO_SHORT';
    }

    // Languages validation
    if (state.languages.isEmpty) {
      languagesError = 'REQUIRED';
    }

    // Specialties validation
    if (state.specialties.isEmpty) {
      specialtiesError = 'REQUIRED';
    }

    // Bio validation
    if (state.bio.trim().isEmpty) {
      bioError = 'REQUIRED';
    } else if (state.bio.trim().length < 10) {
      bioError = 'TOO_SHORT';
    }

    // Contact validation (Egyptian mobile number)
    final digits = state.contact.replaceAll(RegExp(r'[\s-]'), '');
    if (digits.isEmpty) {
      contactError = 'REQUIRED';
    } else if (!_egyptPhone.hasMatch(digits)) {
      contactError = 'INVALID_PHONE';
    }

    state = state.copyWith(
      fullNameError: () => fullNameError,
      languagesError: () => languagesError,
      specialtiesError: () => specialtiesError,
      bioError: () => bioError,
      contactError: () => contactError,
    );

    return fullNameError == null &&
        languagesError == null &&
        specialtiesError == null &&
        bioError == null &&
        contactError == null &&
        state.photoError == null;
  }

  Future<Result<GuideApplicationResult>> submit() async {
    if (!validate()) {
      return const Result.failure(Failure(ErrorCodes.validation));
    }

    state = state.copyWith(isSubmitting: true, serverError: () => null);

    final repository = ref.read(localGuidesRepositoryProvider);
    final result = await repository.createGuideApplication(state.toEntity());

    switch (result) {
      case Success():
        state = state.copyWith(isSubmitting: false);
        return result;

      case Error(:final failure):
        String? contactError;
        String? photoError;
        String? fullNameError;
        String? serverError;

        if (failure.code == 'ALREADY_APPLIED') {
          contactError = 'ALREADY_APPLIED';
          serverError = 'ALREADY_APPLIED';
        } else if (failure.code == ErrorCodes.validation) {
          final details = failure.fieldErrors;
          if (details['contact'] != null) {
            contactError = details['contact'];
          }
          if (details['full_name'] != null) {
            fullNameError = details['full_name'];
          }
          if (details['profile_photo'] != null) {
            photoError = details['profile_photo'];
          }
          serverError = 'VALIDATION_ERROR';
        } else {
          serverError = failure.code;
        }

        state = state.copyWith(
          isSubmitting: false,
          contactError: () => contactError ?? state.contactError,
          photoError: () => photoError ?? state.photoError,
          fullNameError: () => fullNameError ?? state.fullNameError,
          serverError: () => serverError,
        );

        return result;
    }
  }

  void reset() {
    state = const GuideApplicationFormState();
  }
}
