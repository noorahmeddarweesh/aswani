import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env.dart';
import 'data/datasources/places_datasource.dart';
import 'data/datasources/places_mock_datasource.dart';
import 'data/repositories/places_repository_impl.dart';
import 'domain/repositories/places_repository.dart';

final placesDataSourceProvider = Provider<PlacesDataSource>((ref) {
  assert(
    Env.useMocks,
    'Remote places data source not implemented yet: run with USE_MOCKS=true',
  );
  return PlacesMockDataSource();
});

final placesRepositoryProvider = Provider<PlacesRepository>(
  (ref) => PlacesRepositoryImpl(ref.watch(placesDataSourceProvider)),
);
