/// Build-time configuration, passed with --dart-define:
///
/// ```sh
/// flutter run --dart-define=USE_MOCKS=true
/// flutter run --dart-define=USE_MOCKS=false --dart-define=BASE_URL=https://api.example.com/api
/// ```
///
/// Only the dependency-injection providers read [useMocks]; nothing else in
/// the app may branch on it.
abstract final class Env {
  static const bool useMocks = bool.fromEnvironment(
    'USE_MOCKS',
    defaultValue: true,
  );

  /// 10.0.2.2 is the host machine as seen from the Android emulator.
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  static const String mapboxToken = String.fromEnvironment('MAPBOX_TOKEN');

  /// Shown in Settings > About. Keep in step with `version:` in pubspec.yaml
  /// (test/core/config/env_test.dart checks it).
  static const String appVersion = '0.1.0';
}
