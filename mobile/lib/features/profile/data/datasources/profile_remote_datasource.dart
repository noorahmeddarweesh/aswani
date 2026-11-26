import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/upload.dart';
import '../../../../core/pagination/paged.dart';
import 'profile_datasource.dart';

/// Profile & Settings endpoints of the real API (contract v0.2).
class ProfileRemoteDataSource implements ProfileDataSource {
  ProfileRemoteDataSource(this._client);

  final Dio _client;

  Map<String, dynamic> _data(Response<Map<String, dynamic>> r) =>
      r.data!['data'] as Map<String, dynamic>;

  @override
  Future<Map<String, dynamic>> getProfile() => apiCall(
    () async =>
        _data(await _client.get<Map<String, dynamic>>('/users/me/profile')),
  );

  @override
  Future<String> uploadAvatar(UploadFile photo) => apiCall(() async {
    final r = await _client.put<Map<String, dynamic>>(
      '/users/me/avatar',
      data: buildFormData(filesField: 'avatar', files: [photo]),
    );
    return _data(r)['avatar'] as String;
  });

  @override
  Future<Paged<Map<String, dynamic>>> getSaved({String? type, int page = 1}) =>
      apiCall(() async {
        final r = await _client.get<Map<String, dynamic>>(
          '/saved',
          queryParameters: {'type': ?type, 'page': page, 'limit': kPageSize},
        );
        return Paged.fromJson(r.data!, (e) => e);
      });

  @override
  Future<Map<String, dynamic>> getSettings() => apiCall(
    () async =>
        _data(await _client.get<Map<String, dynamic>>('/users/settings')),
  );

  @override
  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> body) =>
      apiCall(
        () async => _data(
          await _client.patch<Map<String, dynamic>>(
            '/users/settings',
            data: body,
          ),
        ),
      );

  @override
  Future<void> requestDeletion() =>
      apiCall(() => _client.post<void>('/users/me/deletion-request'));
}
