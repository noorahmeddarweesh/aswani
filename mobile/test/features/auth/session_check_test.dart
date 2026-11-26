import 'package:aswani/core/session/session_controller.dart';
import 'package:aswani/core/storage/app_bootstrap.dart';
import 'package:aswani/core/storage/key_value_store.dart';
import 'package:aswani/features/auth/auth_providers.dart';
import 'package:aswani/features/auth/data/datasources/auth_mock_datasource.dart';
import 'package:aswani/features/auth/presentation/viewmodels/session_check.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ProviderContainer _launch(Map<String, String> savedTokens) {
  final secure = MemoryKeyValueStore(savedTokens);
  final container = ProviderContainer(
    overrides: [
      secureStoreProvider.overrideWithValue(secure),
      startupStateProvider.overrideWithValue(
        const StartupState(
          session: Session(userId: 'u_1', displayName: 'Old name'),
        ),
      ),
      authDataSourceProvider.overrideWithValue(
        AuthMockDataSource(delay: Duration.zero, tokens: secure),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('a valid saved session is refreshed from the server', () async {
    final container = _launch({StorageKeys.accessToken: 'mock-access-u_1'});
    await container.read(sessionCheckProvider.future);
    final session = container.read(sessionProvider);
    expect(session?.displayName, 'Laila');
    expect(session?.hasPreferences, isTrue);
    expect(session?.avatarUrl, isNotNull);
  });

  test('an expired session signs out on launch', () async {
    final container = _launch({});
    await container.read(sessionCheckProvider.future);
    expect(container.read(sessionProvider), isNull);
  });
}
