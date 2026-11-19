import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/app_bootstrap.dart';
import '../storage/key_value_store.dart';

/// Who is signed in, and whether they finished personalisation.
///
/// Lives in core (not in the auth feature) because the router and several
/// features read it. Saved in secure storage, so the user stays signed in
/// after closing the app.
/// TODO(api): on launch, confirm the saved session with GET /api/users/me.
class Session {
  const Session({
    required this.userId,
    required this.displayName,
    this.hasPreferences = false,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
    userId: json['user_id'] as String,
    displayName: json['display_name'] as String,
    hasPreferences: json['has_preferences'] as bool? ?? false,
  );

  final String userId;
  final String displayName;
  final bool hasPreferences;

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'display_name': displayName,
    'has_preferences': hasPreferences,
  };

  Session copyWith({bool? hasPreferences}) => Session(
    userId: userId,
    displayName: displayName,
    hasPreferences: hasPreferences ?? this.hasPreferences,
  );
}

class SessionController extends Notifier<Session?> {
  @override
  Session? build() => ref.read(startupStateProvider).session;

  KeyValueStore get _store => ref.read(secureStoreProvider);

  void _save(Session? session) {
    state = session;
    unawaited(
      session == null
          ? _store.delete(StorageKeys.session)
          : _store.write(StorageKeys.session, jsonEncode(session.toJson())),
    );
  }

  void signedIn(Session session) => _save(session);

  void preferencesSaved() => _save(state?.copyWith(hasPreferences: true));

  void signOut() {
    _save(null);
    unawaited(_store.delete(StorageKeys.accessToken));
    unawaited(_store.delete(StorageKeys.refreshToken));
  }
}

final sessionProvider = NotifierProvider<SessionController, Session?>(
  SessionController.new,
);
