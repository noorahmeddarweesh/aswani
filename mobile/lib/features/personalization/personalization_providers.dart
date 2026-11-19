import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env.dart';
import '../../core/network/api_client.dart';
import 'data/datasources/preferences_datasource.dart';
import 'data/datasources/preferences_mock_datasource.dart';
import 'data/datasources/preferences_remote_datasource.dart';
import 'data/repositories/preferences_repository_impl.dart';
import 'domain/repositories/preferences_repository.dart';

final preferencesDataSourceProvider = Provider<PreferencesDataSource>(
  (ref) => Env.useMocks
      ? PreferencesMockDataSource()
      : PreferencesRemoteDataSource(ref.watch(apiClientProvider)),
);

final preferencesRepositoryProvider = Provider<PreferencesRepository>(
  (ref) => PreferencesRepositoryImpl(ref.watch(preferencesDataSourceProvider)),
);
