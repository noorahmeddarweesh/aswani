import '../../core/errors/failure.dart';

/// State of a form that sends something: idle, sending, or failed.
class SubmitState {
  const SubmitState({this.submitting = false, this.failure});

  static const SubmitState idle = SubmitState();
  static const SubmitState sending = SubmitState(submitting: true);

  final bool submitting;
  final Failure? failure;

  /// Server error for one field, if any (e.g. `identifier`).
  String? fieldError(String field) => failure?.fieldErrors[field];
}
