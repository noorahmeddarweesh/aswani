import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/app_bootstrap.dart';
import 'data/datasources/auth_datasource.dart';
import 'data/datasources/auth_mock_datasource.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';

/// Dependency injection for the auth feature.
///
/// The only place that chooses mock or remote (Strategy pattern):
/// `--dart-define=USE_MOCKS=false` switches to the real API at `BASE_URL`.
final authDataSourceProvider = Provider<AuthDataSource>(
  (ref) => Env.useMocks
      ? AuthMockDataSource(tokens: ref.watch(secureStoreProvider))
      : AuthRemoteDataSource(
          ref.watch(apiClientProvider),
          ref.watch(secureStoreProvider),
        ),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.watch(authDataSourceProvider),
    ref.watch(secureStoreProvider),
  ),
);
