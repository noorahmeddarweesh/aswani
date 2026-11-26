import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/preferences_dto.dart';
import 'preferences_datasource.dart';

/// Preferences endpoint of the real API (contract: Preferences section).
class PreferencesRemoteDataSource implements PreferencesDataSource {
  PreferencesRemoteDataSource(this._client);

  final Dio _client;

  @override
  Future<PreferencesDto?> load() => apiCall(() async {
    final r = await _client.get<Map<String, dynamic>>('/users/preferences');
    final body = r.data;
    if (body == null) return null;
    // v0.2 wraps every body in `data`; accept the v0.1 shape too.
    final json = body['data'] as Map<String, dynamic>? ?? body;
    return PreferencesDto.fromJson(json);
  });

  @override
  Future<void> save(PreferencesDto preferences) => apiCall(
    () => _client.put<void>('/users/preferences', data: preferences.toJson()),
  );
}
