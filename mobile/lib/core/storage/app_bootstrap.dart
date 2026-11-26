import 'dart:convert';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:material_ui/material_ui.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

import '../session/session_controller.dart';
import 'key_value_store.dart';

/// What the app restores on launch, read once before the first frame.
class StartupState {
  const StartupState({this.locale, this.themeMode, this.session});

  final Locale? locale;
  final ThemeMode? themeMode;
  final Session? session;
}

/// Storage used by the app. Defaults to memory (tests); `main` replaces them
/// with the real secure and plain stores.
final secureStoreProvider = Provider<KeyValueStore>(
  (ref) => MemoryKeyValueStore(),
);
final prefsStoreProvider = Provider<KeyValueStore>(
  (ref) => MemoryKeyValueStore(),
);
final startupStateProvider = Provider<StartupState>(
  (ref) => const StartupState(),
);

/// Opens storage and reads the saved language, theme and session.
/// Anything unreadable is ignored: the app then starts as on a first launch.
Future<List<Override>> bootstrapStorage() async {
  final prefs = PrefsKeyValueStore(await SharedPreferences.getInstance());
  final secure = SecureKeyValueStore();

  Locale? locale;
  ThemeMode? themeMode;
  Session? session;
  try {
    final code = await prefs.read(StorageKeys.locale);
    if (code == 'ar' || code == 'en') locale = Locale(code!);
    final mode = await prefs.read(StorageKeys.themeMode);
    themeMode = ThemeMode.values.where((m) => m.name == mode).firstOrNull;
    final json = await secure.read(StorageKeys.session);
    if (json != null) {
      session = Session.fromJson(jsonDecode(json) as Map<String, dynamic>);
    }
  } on Object {
    // Corrupt or unavailable storage: start fresh.
  }

  return [
    secureStoreProvider.overrideWithValue(secure),
    prefsStoreProvider.overrideWithValue(prefs),
    startupStateProvider.overrideWithValue(
      StartupState(locale: locale, themeMode: themeMode, session: session),
    ),
  ];
}
