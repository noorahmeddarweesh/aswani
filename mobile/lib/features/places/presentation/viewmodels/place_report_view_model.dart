import 'package:aswani/core/result/result.dart';
import 'package:aswani/features/places/domain/entities/place_details.dart';
import 'package:aswani/features/places/domain/entities/place_report.dart';
import 'package:aswani/features/places/place_details_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'place_report_form_state.dart';

/// ViewModel managing state, validation, and submission for the 3-step Place Report flow.
class PlaceReportViewModel extends Notifier<PlaceReportFormState> {
  @override
  PlaceReportFormState build() => const PlaceReportFormState();

  /// Initializes the form with a place ID and optionally pre-loaded place details.
  Future<void> init(String placeId, {PlaceDetails? place}) async {
    state = state.copyWith(
      placeId: placeId,
      place: () => place,
      serverError: () => null,
    );

    if (place == null && placeId.isNotEmpty) {
      final repo = ref.read(placeDetailsRepositoryProvider);
      final result = await repo.getPlaceDetails(placeId);
      if (result case Success(:final value)) {
        state = state.copyWith(place: () => value);
      }
    }
  }

  /// Sets the selected reason in Step 1 (What Needs Updating).
  void selectReason(PlaceReportReason reason) {
    state = state.copyWith(reason: () => reason, serverError: () => null);
  }

  /// Updates details text in Step 2.
  void setDetails(String value) {
    String? detailsError;
    if (value.trim().length > 1000) {
      detailsError = 'DETAILS_TOO_LONG';
    }

    state = state.copyWith(
      details: value,
      detailsError: () => detailsError,
      serverError: () => null,
    );
  }

  /// Sets or removes a supporting photo with client-side file validation.
  void setPhoto(String? path) {
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
      photo: () => path,
      photoError: () => photoError,
      serverError: () => null,
    );
  }

  void removePhoto() {
    setPhoto(null);
  }

  /// Submits the report via PlaceDetailsRepository.
  Future<bool> submit() async {
    final trimmedDetails = state.details.trim();
    if (state.reason == null) {
      state = state.copyWith(serverError: () => 'REASON_REQUIRED');
      return false;
    }

    if (trimmedDetails.isEmpty) {
      state = state.copyWith(detailsError: () => 'DETAILS_REQUIRED');
      return false;
    }

    if (trimmedDetails.length > 1000) {
      state = state.copyWith(detailsError: () => 'DETAILS_TOO_LONG');
      return false;
    }

    if (state.photoError != null) {
      return false;
    }

    state = state.copyWith(isSubmitting: true, serverError: () => null);

    final report = PlaceReportCreate(
      placeId: state.placeId,
      reason: state.reason!,
      details: trimmedDetails,
      photo: state.photo,
    );

    final repo = ref.read(placeDetailsRepositoryProvider);
    final result = await repo.createPlaceReport(report);

    if (!ref.mounted) return false;

    return switch (result) {
      Success(:final value) => () {
        state = state.copyWith(isSubmitting: false, result: () => value);
        return true;
      }(),
      Error(:final failure) => () {
        state = state.copyWith(
          isSubmitting: false,
          serverError: () => failure.code,
          detailsError: () => failure.fieldErrors['details'],
          photoError: () => failure.fieldErrors['photo'],
        );
        return false;
      }(),
    };
  }

  /// Resets the form state.
  void reset() {
    state = const PlaceReportFormState();
  }
}

final placeReportViewModelProvider =
    NotifierProvider.autoDispose<PlaceReportViewModel, PlaceReportFormState>(
      PlaceReportViewModel.new,
    );
