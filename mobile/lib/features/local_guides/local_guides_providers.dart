import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env.dart';
import '../../core/network/api_client.dart';
import 'data/datasources/local_guides_datasource.dart';
import 'data/datasources/local_guides_mock_datasource.dart';
import 'data/datasources/local_guides_remote_datasource.dart';
import 'data/repositories/local_guides_repository_impl.dart';
import 'domain/repositories/local_guides_repository.dart';

final localGuidesDataSourceProvider = Provider<LocalGuidesDataSource>(
  (ref) => Env.useMocks
      ? LocalGuidesMockDataSource()
      : LocalGuidesRemoteDataSource(ref.watch(apiClientProvider)),
);

final localGuidesRepositoryProvider = Provider<LocalGuidesRepository>(
  (ref) => LocalGuidesRepositoryImpl(ref.watch(localGuidesDataSourceProvider)),
);
