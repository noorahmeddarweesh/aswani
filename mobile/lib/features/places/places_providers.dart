import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env.dart';
import '../../core/network/api_client.dart';
import 'data/datasources/places_datasource.dart';
import 'data/datasources/places_mock_datasource.dart';
import 'data/datasources/places_remote_datasource.dart';
import 'data/repositories/places_repository_impl.dart';
import 'domain/repositories/places_repository.dart';

final placesDataSourceProvider = Provider<PlacesDataSource>(
  (ref) => Env.useMocks
      ? PlacesMockDataSource()
      : PlacesRemoteDataSource(ref.watch(apiClientProvider)),
);

final placesRepositoryProvider = Provider<PlacesRepository>(
  (ref) => PlacesRepositoryImpl(ref.watch(placesDataSourceProvider)),
);
