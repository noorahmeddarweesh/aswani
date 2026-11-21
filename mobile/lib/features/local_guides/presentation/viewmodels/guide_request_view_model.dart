import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/guide_enums.dart';
import 'guide_request_form_state.dart';

/// Manages the state and business validations for requesting a local guide.
class GuideRequestViewModel extends Notifier<GuideRequestFormState> {
  GuideRequestViewModel(this.guideId);

  final String guideId;

  @override
  GuideRequestFormState build() {
    return GuideRequestFormState(guideId: guideId);
  }

  /// Updates preferred date and performs Cairo calendar validation.
  void setDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) {
      state = state.copyWith(
        clearDate: true,
        dateError: 'REQUIRED',
      );
      return;
    }

    final trimmed = dateStr.trim();
    if (!isCairoDateTodayOrFuture(trimmed)) {
      state = state.copyWith(
        date: trimmed,
        dateError: 'DATE_IN_PAST',
      );
      return;
    }

    state = state.copyWith(
      date: trimmed,
      clearDateError: true,
    );
  }

  /// Sets the selected duration. Enforces:
  /// - `one_day`: default `duration_hours = 6`
  /// - `custom`: requires 1..12 (defaults to 4 if previously null)
  /// - `few_hours`, `two_days`, `three_days`: clears `duration_hours` to null.
  void setDuration(RequestDuration duration) {
    if (duration == RequestDuration.oneDay) {
      state = state.copyWith(
        duration: duration,
        durationHours: 6,
        clearCustomHoursError: true,
      );
    } else if (duration == RequestDuration.custom) {
      final hours = (state.durationHours != null &&
              state.durationHours! >= 1 &&
              state.durationHours! <= 12)
          ? state.durationHours
          : 4;
      state = state.copyWith(
        duration: duration,
        durationHours: hours,
        clearCustomHoursError: true,
      );
    } else {
      state = state.copyWith(
        duration: duration,
        clearDurationHours: true,
        clearCustomHoursError: true,
      );
    }
  }

  /// Sets custom duration hours (1..12).
  void setCustomHours(int hours) {
    if (hours < 1 || hours > 12) {
      state = state.copyWith(
        durationHours: hours,
        customHoursError: 'INVALID_HOURS',
      );
      return;
    }

    state = state.copyWith(
      durationHours: hours,
      clearCustomHoursError: true,
    );
  }

  /// Sets start time in HH:mm 24-hr format.
  void setStartTime(String time) {
    state = state.copyWith(startTime: time);
  }

  /// Sets group size clamped between 1 and 20.
  void setGroupSize(int count) {
    final clamped = count.clamp(1, 20);
    state = state.copyWith(groupSize: clamped);
  }

  /// Sets preferred language.
  void setLanguage(GuideLanguage language) {
    state = state.copyWith(language: language);
  }

  /// Sets optional additional notes.
  void setNotes(String? notes) {
    state = state.copyWith(notes: notes);
  }

  /// Validates all required fields before navigating to the Review screen.
  bool validate() {
    String? dateError;
    if (state.date == null || state.date!.trim().isEmpty) {
      dateError = 'REQUIRED';
    } else if (!isCairoDateTodayOrFuture(state.date!)) {
      dateError = 'DATE_IN_PAST';
    }

    String? customHoursError;
    if (state.duration == RequestDuration.custom) {
      if (state.durationHours == null ||
          state.durationHours! < 1 ||
          state.durationHours! > 12) {
        customHoursError = 'INVALID_HOURS';
      }
    }

    state = state.copyWith(
      dateError: dateError,
      clearDateError: dateError == null,
      customHoursError: customHoursError,
      clearCustomHoursError: customHoursError == null,
    );

    return dateError == null && customHoursError == null;
  }

  /// Resets the form state back to initial defaults after confirmed submission.
  void reset() {
    state = GuideRequestFormState(guideId: guideId);
  }
}

/// Riverpod family provider for [GuideRequestViewModel].
final guideRequestViewModelProvider = NotifierProvider.autoDispose
    .family<GuideRequestViewModel, GuideRequestFormState, String>(
  GuideRequestViewModel.new,
);
