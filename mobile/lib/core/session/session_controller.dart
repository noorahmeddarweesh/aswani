import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Who is signed in, and whether they finished personalisation.
///
/// Lives in core (not in the auth feature) because the router and several
/// features read it. Kept in memory for now.
/// TODO(sprint-1): restore the session from secure storage on launch.
class Session {
  const Session({
    required this.userId,
    required this.displayName,
    this.hasPreferences = false,
  });

  final String userId;
  final String displayName;
  final bool hasPreferences;

  Session copyWith({bool? hasPreferences}) => Session(
    userId: userId,
    displayName: displayName,
    hasPreferences: hasPreferences ?? this.hasPreferences,
  );
}

class SessionController extends Notifier<Session?> {
  @override
  Session? build() => null;

  void signedIn(Session session) => state = session;

  void preferencesSaved() => state = state?.copyWith(hasPreferences: true);

  void signOut() => state = null;
}

final sessionProvider = NotifierProvider<SessionController, Session?>(
  SessionController.new,
);
