import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App language. Arabic and English are supported; the user picks one in the
/// last personalisation step and can change it in Settings.
///
/// TODO(sprint-2): persist the choice with shared_preferences.
class LocaleController extends Notifier<Locale> {
  static const Locale english = Locale('en');
  static const Locale arabic = Locale('ar');

  @override
  Locale build() => english;

  void setLocale(Locale locale) => state = locale;

  void toggle() => state = state == arabic ? english : arabic;
}

final localeProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);

/// Light / dark / system theme.
///
/// TODO(sprint-2): persist the choice with shared_preferences.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  void setMode(ThemeMode mode) => state = mode;

  void toggle() =>
      state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
