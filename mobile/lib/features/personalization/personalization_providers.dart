import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env.dart';
import 'data/datasources/preferences_datasource.dart';
import 'data/datasources/preferences_mock_datasource.dart';
import 'data/repositories/preferences_repository_impl.dart';
import 'domain/repositories/preferences_repository.dart';

final preferencesDataSourceProvider = Provider<PreferencesDataSource>((ref) {
  assert(
    Env.useMocks,
    'Remote preferences data source not implemented yet: run with USE_MOCKS=true',
  );
  return PreferencesMockDataSource();
});

final preferencesRepositoryProvider = Provider<PreferencesRepository>(
  (ref) => PreferencesRepositoryImpl(ref.watch(preferencesDataSourceProvider)),
);
