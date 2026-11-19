import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../../../shared/state/submit_state.dart';
import '../../auth_providers.dart';

class ResetPasswordViewModel extends Notifier<SubmitState> {
  @override
  SubmitState build() => SubmitState.idle;

  /// Returns true when the password was changed.
  Future<bool> submit({
    required String identifier,
    required String code,
    required String newPassword,
  }) async {
    if (state.submitting) return false;
    state = SubmitState.sending;
    final result = await ref
        .read(authRepositoryProvider)
        .resetPassword(
          identifier: identifier,
          code: code.trim(),
          newPassword: newPassword,
        );
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

final resetPasswordViewModelProvider =
    NotifierProvider.autoDispose<ResetPasswordViewModel, SubmitState>(
      ResetPasswordViewModel.new,
    );
