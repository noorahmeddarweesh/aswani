import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env.dart';
import '../../core/network/api_client.dart';
import 'data/datasources/culture_datasource.dart';
import 'data/datasources/culture_mock_datasource.dart';
import 'data/datasources/culture_remote_datasource.dart';
import 'data/repositories/culture_repository_impl.dart';
import 'domain/repositories/culture_repository.dart';

/// The only place that chooses mock or remote for Culture.
final cultureDataSourceProvider = Provider<CultureDataSource>(
  (ref) => Env.useMocks
      ? CultureMockDataSource()
      : CultureRemoteDataSource(ref.watch(apiClientProvider)),
);

final cultureRepositoryProvider = Provider<CultureRepository>(
  (ref) => CultureRepositoryImpl(ref.watch(cultureDataSourceProvider)),
);
