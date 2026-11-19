import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/session/session_controller.dart';
import '../../auth_providers.dart';
import 'sign_in_view_model.dart';

/// Runs once on launch: asks the server who the saved session belongs to
/// (GET /api/users/me) and refreshes the name, photo and personalisation
/// flag. An expired session signs out; no network keeps the saved session
/// so the app still opens offline.
final sessionCheckProvider = FutureProvider<void>((ref) async {
  if (ref.read(sessionProvider) == null) return;
  final result = await ref.read(authRepositoryProvider).currentUser();
  final session = ref.read(sessionProvider.notifier);
  switch (result) {
    case Success(:final value):
      session.signedIn(value.toSession());
    case Error(:final failure) when failure.code == ErrorCodes.unauthorized:
      session.signOut();
    case Error():
      break;
  }
});
