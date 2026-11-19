import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_settings.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/session/session_controller.dart';
import '../../domain/entities/preferences.dart';
import '../../personalization_providers.dart';

class PersonalizationState {
  const PersonalizationState({
    this.step = 0,
    this.preferences = const Preferences(),
    this.submitting = false,
    this.failure,
  });

  static const int stepCount = 8;

  /// 0-based.
  final int step;
  final Preferences preferences;
  final bool submitting;
  final Failure? failure;

  bool get isLast => step == stepCount - 1;

  /// Whether the current step has an answer (enables Continue).
  bool get hasAnswer => switch (step) {
    0 => preferences.persona != null,
    1 => preferences.purpose != null,
    2 => preferences.stayLength != null,
    3 => preferences.interests.isNotEmpty,
    4 => preferences.styles.isNotEmpty,
    5 => preferences.companions != null,
    6 => preferences.needs.isNotEmpty,
    _ => true,
  };

  PersonalizationState copyWith({
    int? step,
    Preferences? preferences,
    bool? submitting,
    Failure? failure,
    bool clearFailure = false,
  }) => PersonalizationState(
    step: step ?? this.step,
    preferences: preferences ?? this.preferences,
    submitting: submitting ?? this.submitting,
    failure: clearFailure ? null : failure ?? this.failure,
  );
}

Set<T> _toggle<T>(Set<T> set, T value) =>
    set.contains(value) ? ({...set}..remove(value)) : {...set, value};

class PersonalizationViewModel extends Notifier<PersonalizationState> {
  @override
  PersonalizationState build() => PersonalizationState(
    preferences: Preferences(
      languageCode: ref.read(localeProvider).languageCode,
    ),
  );

  void _update(Preferences preferences) =>
      state = state.copyWith(preferences: preferences, clearFailure: true);

  Preferences get _p => state.preferences;

  void selectPersona(Persona v) => _update(_p.copyWith(persona: v));
  void selectPurpose(Purpose v) => _update(_p.copyWith(purpose: v));
  void selectStay(StayLength v) => _update(_p.copyWith(stayLength: v));
  void toggleInterest(Interest v) =>
      _update(_p.copyWith(interests: _toggle(_p.interests, v)));
  void toggleStyle(TravelStyle v) =>
      _update(_p.copyWith(styles: _toggle(_p.styles, v)));
  void selectCompanions(Companions v) => _update(_p.copyWith(companions: v));
  void toggleNeed(Need v) => _update(_p.copyWith(needs: _toggle(_p.needs, v)));

  /// Applies the language at once, so the user sees the choice.
  void selectLanguage(String code) {
    _update(_p.copyWith(languageCode: code));
    ref.read(localeProvider.notifier).setLocale(Locale(code));
  }

  void back() {
    if (state.step > 0) state = state.copyWith(step: state.step - 1);
  }

  /// Continue or Skip. On the last step, saves and finishes.
  Future<void> next() async {
    if (!state.isLast) {
      state = state.copyWith(step: state.step + 1);
      return;
    }
    if (state.submitting) return;
    state = state.copyWith(submitting: true, clearFailure: true);
    final result = await ref.read(preferencesRepositoryProvider).save(_p);
    if (!ref.mounted) return;
    switch (result) {
      case Success():
        state = state.copyWith(submitting: false);
        ref.read(sessionProvider.notifier).preferencesSaved();
      case Error(:final failure):
        state = state.copyWith(submitting: false, failure: failure);
    }
  }
}

final personalizationViewModelProvider =
    NotifierProvider.autoDispose<
      PersonalizationViewModel,
      PersonalizationState
    >(PersonalizationViewModel.new);
