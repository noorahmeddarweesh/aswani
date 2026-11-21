import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env.dart';
import '../../core/network/api_client.dart';
import 'data/datasources/place_details_datasource.dart';
import 'data/datasources/place_details_mock_datasource.dart';
import 'data/datasources/place_details_remote_datasource.dart';
import 'data/repositories/place_details_repository_impl.dart';
import 'domain/repositories/place_details_repository.dart';

final placeDetailsDataSourceProvider = Provider<PlaceDetailsDataSource>(
  (ref) => Env.useMocks
      ? PlaceDetailsMockDataSource()
      : PlaceDetailsRemoteDataSource(ref.watch(apiClientProvider)),
);

final placeDetailsRepositoryProvider = Provider<PlaceDetailsRepository>(
  (ref) =>
      PlaceDetailsRepositoryImpl(ref.watch(placeDetailsDataSourceProvider)),
);
