import 'dart:convert';

import 'package:aswani/core/config/app_settings.dart';
import 'package:aswani/core/session/session_controller.dart';
import 'package:aswani/core/storage/app_bootstrap.dart';
import 'package:aswani/core/storage/key_value_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('language and theme are saved and restored', () async {
    final prefs = MemoryKeyValueStore();
    final first = ProviderContainer(
      overrides: [prefsStoreProvider.overrideWithValue(prefs)],
    );
    first.read(localeProvider.notifier).setLocale(LocaleController.arabic);
    first.read(themeModeProvider.notifier).setMode(ThemeMode.dark);
    await Future<void>.delayed(Duration.zero);
    first.dispose();

    expect(await prefs.read(StorageKeys.locale), 'ar');
    expect(await prefs.read(StorageKeys.themeMode), 'dark');

    final restored = ProviderContainer(
      overrides: [
        startupStateProvider.overrideWithValue(
          const StartupState(
            locale: LocaleController.arabic,
            themeMode: ThemeMode.dark,
          ),
        ),
      ],
    );
    addTearDown(restored.dispose);
    expect(restored.read(localeProvider), LocaleController.arabic);
    expect(restored.read(themeModeProvider), ThemeMode.dark);
  });

  test('session is saved securely and cleared on sign out', () async {
    final secure = MemoryKeyValueStore({
      StorageKeys.accessToken: 'a',
      StorageKeys.refreshToken: 'r',
    });
    final container = ProviderContainer(
      overrides: [secureStoreProvider.overrideWithValue(secure)],
    );
    addTearDown(container.dispose);
    final session = container.read(sessionProvider.notifier);

    session.signedIn(const Session(userId: 'u1', displayName: 'Laila'));
    session.preferencesSaved();
    await Future<void>.delayed(Duration.zero);
    final saved = jsonDecode((await secure.read(StorageKeys.session))!);
    expect(saved, {
      'user_id': 'u1',
      'display_name': 'Laila',
      'has_preferences': true,
    });

    session.signOut();
    await Future<void>.delayed(Duration.zero);
    expect(await secure.read(StorageKeys.session), isNull);
    expect(await secure.read(StorageKeys.accessToken), isNull);
  });

  test('a restored session opens the app signed in', () {
    final container = ProviderContainer(
      overrides: [
        startupStateProvider.overrideWithValue(
          StartupState(
            session: Session.fromJson(const {
              'user_id': 'u1',
              'display_name': 'Laila',
              'has_preferences': true,
            }),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    expect(container.read(sessionProvider)?.displayName, 'Laila');
  });
}
