import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env.dart';
import '../../core/network/api_client.dart';
import 'data/datasources/contributions_datasource.dart';
import 'data/datasources/contributions_mock_datasource.dart';
import 'data/datasources/contributions_remote_datasource.dart';
import 'data/repositories/contributions_repository_impl.dart';
import 'domain/repositories/contributions_repository.dart';

/// The only place that chooses mock or remote for contributions.
final contributionsDataSourceProvider = Provider<ContributionsDataSource>(
  (ref) => Env.useMocks
      ? ContributionsMockDataSource()
      : ContributionsRemoteDataSource(ref.watch(apiClientProvider)),
);

final contributionsRepositoryProvider = Provider<ContributionsRepository>(
  (ref) =>
      ContributionsRepositoryImpl(ref.watch(contributionsDataSourceProvider)),
);
