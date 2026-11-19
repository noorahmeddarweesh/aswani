import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/preferences_dto.dart';
import 'preferences_datasource.dart';

/// Preferences endpoint of the real API (contract: Preferences section).
class PreferencesRemoteDataSource implements PreferencesDataSource {
  PreferencesRemoteDataSource(this._client);

  final Dio _client;

  @override
  Future<void> save(PreferencesDto preferences) => apiCall(
    () => _client.put<void>('/users/preferences', data: preferences.toJson()),
  );
}
