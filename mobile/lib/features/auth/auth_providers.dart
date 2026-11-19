import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env.dart';
import 'data/datasources/auth_datasource.dart';
import 'data/datasources/auth_mock_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';

/// Dependency injection for the auth feature.
///
/// The only place that chooses mock or remote (Strategy pattern). The remote
/// data source is added when the backend endpoints are ready.
final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  assert(
    Env.useMocks,
    'Remote auth data source not implemented yet: run with USE_MOCKS=true',
  );
  return AuthMockDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(authDataSourceProvider)),
);
