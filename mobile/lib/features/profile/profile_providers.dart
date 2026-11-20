import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env.dart';
import '../../core/network/api_client.dart';
import 'data/datasources/profile_datasource.dart';
import 'data/datasources/profile_mock_datasource.dart';
import 'data/datasources/profile_remote_datasource.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'domain/repositories/profile_repository.dart';

// The only place that picks mock or real data for Profile & Settings.

final profileDataSourceProvider = Provider<ProfileDataSource>(
  (ref) => Env.useMocks
      ? ProfileMockDataSource()
      : ProfileRemoteDataSource(ref.watch(apiClientProvider)),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(ref.watch(profileDataSourceProvider)),
);
