import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../shared/state/submit_state.dart';
import '../../auth_providers.dart';
import 'sign_in_view_model.dart';

class SignUpViewModel extends Notifier<SubmitState> {
  @override
  SubmitState build() => SubmitState.idle;

  Future<void> submit({
    required String fullName,
    required String identifier,
    required String password,
  }) async {
    if (state.submitting) return;
    state = SubmitState.sending;
    final result = await ref
        .read(authRepositoryProvider)
        .signUp(
          fullName: fullName.trim(),
          identifier: identifier.trim(),
          password: password,
        );
    if (!ref.mounted) return;
    switch (result) {
      case Success(:final value):
        state = SubmitState.idle;
        ref.read(sessionProvider.notifier).signedIn(value.toSession());
      case Error(:final failure):
        state = SubmitState(failure: failure);
    }
  }
}

final signUpViewModelProvider =
    NotifierProvider.autoDispose<SignUpViewModel, SubmitState>(
      SignUpViewModel.new,
    );
