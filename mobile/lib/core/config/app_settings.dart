import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../storage/app_bootstrap.dart';
import '../storage/key_value_store.dart';

/// App language: Arabic or English. Saved, so the app reopens in the same
/// language. On a first launch it follows the phone's language.
class LocaleController extends Notifier<Locale> {
  static const Locale english = Locale('en');
  static const Locale arabic = Locale('ar');

  @override
  Locale build() {
    final saved = ref.read(startupStateProvider).locale;
    if (saved != null) return saved;
    final device = PlatformDispatcher.instance.locale.languageCode;
    return device == 'ar' ? arabic : english;
  }

  void setLocale(Locale locale) {
    state = locale;
    unawaited(
      ref
          .read(prefsStoreProvider)
          .write(StorageKeys.locale, locale.languageCode),
    );
  }

  void toggle() => setLocale(state == arabic ? english : arabic);
}

final localeProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);

/// Light / dark / system theme. Saved like the language.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() =>
      ref.read(startupStateProvider).themeMode ?? ThemeMode.light;

  void setMode(ThemeMode mode) {
    state = mode;
    unawaited(
      ref.read(prefsStoreProvider).write(StorageKeys.themeMode, mode.name),
    );
  }

  void toggle() =>
      setMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
