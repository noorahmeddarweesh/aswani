import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../../../shared/state/submit_state.dart';
import '../../auth_providers.dart';

class ForgotPasswordViewModel extends Notifier<SubmitState> {
  @override
  SubmitState build() => SubmitState.idle;

  /// Returns true when the code was sent.
  Future<bool> submit({required String identifier}) async {
    if (state.submitting) return false;
    state = SubmitState.sending;
    final result = await ref
        .read(authRepositoryProvider)
        .requestPasswordReset(identifier: identifier.trim());
    if (!ref.mounted) return false;
    switch (result) {
      case Success():
        state = SubmitState.idle;
        return true;
      case Error(:final failure):
        state = SubmitState(failure: failure);
        return false;
    }
  }
}

final forgotPasswordViewModelProvider =
    NotifierProvider.autoDispose<ForgotPasswordViewModel, SubmitState>(
      ForgotPasswordViewModel.new,
    );
