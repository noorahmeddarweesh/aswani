import 'package:aswani/features/places/domain/entities/place_details.dart';
import 'package:aswani/features/places/domain/entities/place_report.dart';

import '../../../../core/network/upload.dart';

/// Form state for the 3-step Place Report flow.
class PlaceReportFormState {
  const PlaceReportFormState({
    this.placeId = '',
    this.place,
    this.reason,
    this.details = '',
    this.photo,
    this.detailsError,
    this.photoError,
    this.serverError,
    this.isSubmitting = false,
    this.result,
  });

  final String placeId;
  final PlaceDetails? place;
  final PlaceReportReason? reason;
  final String details;
  final UploadFile? photo;
  final String? detailsError;
  final String? photoError;
  final String? serverError;
  final bool isSubmitting;
  final PlaceReportResult? result;

  bool get canContinueFromReason => reason != null;

  bool get canSubmit =>
      reason != null &&
      details.trim().isNotEmpty &&
      details.trim().length <= 1000 &&
      detailsError == null &&
      photoError == null &&
      !isSubmitting;

  PlaceReportFormState copyWith({
    String? placeId,
    PlaceDetails? Function()? place,
    PlaceReportReason? Function()? reason,
    String? details,
    UploadFile? Function()? photo,
    String? Function()? detailsError,
    String? Function()? photoError,
    String? Function()? serverError,
    bool? isSubmitting,
    PlaceReportResult? Function()? result,
  }) {
    return PlaceReportFormState(
      placeId: placeId ?? this.placeId,
      place: place != null ? place() : this.place,
      reason: reason != null ? reason() : this.reason,
      details: details ?? this.details,
      photo: photo != null ? photo() : this.photo,
      detailsError: detailsError != null ? detailsError() : this.detailsError,
      photoError: photoError != null ? photoError() : this.photoError,
      serverError: serverError != null ? serverError() : this.serverError,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      result: result != null ? result() : this.result,
    );
  }
}
