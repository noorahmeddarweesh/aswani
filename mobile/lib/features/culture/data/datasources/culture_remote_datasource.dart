import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/pagination/paged.dart';
import 'culture_datasource.dart';

/// Culture endpoints of the real API (contract v0.2, Culture).
class CultureRemoteDataSource implements CultureDataSource {
  CultureRemoteDataSource(this._client);

  final Dio _client;

  Map<String, dynamic> _data(Response<Map<String, dynamic>> r) =>
      r.data!['data'] as Map<String, dynamic>;

  @override
  Future<Map<String, dynamic>> getHome() => apiCall(
    () async => _data(await _client.get<Map<String, dynamic>>('/culture/home')),
  );

  @override
  Future<Paged<Map<String, dynamic>>> getStories({
    String? theme,
    int page = 1,
  }) => apiCall(() async {
    final r = await _client.get<Map<String, dynamic>>(
      '/culture/stories',
      queryParameters: {'theme': ?theme, 'page': page, 'limit': kPageSize},
    );
    return Paged.fromJson(r.data!, (e) => e);
  });

  @override
  Future<Map<String, dynamic>> getStory(String id) => apiCall(
    () async =>
        _data(await _client.get<Map<String, dynamic>>('/culture/stories/$id')),
  );

  @override
  Future<bool> setSaved(String storyId, {required bool saved}) =>
      apiCall(() async {
        final path = '/culture/stories/$storyId/save';
        final r = saved
            ? await _client.post<Map<String, dynamic>>(path)
            : await _client.delete<Map<String, dynamic>>(path);
        return _data(r)['is_saved'] as bool;
      });

  @override
  Future<Paged<Map<String, dynamic>>> getSaved({int page = 1}) =>
      apiCall(() async {
        final r = await _client.get<Map<String, dynamic>>(
          '/culture/saved',
          queryParameters: {'page': page, 'limit': kPageSize},
        );
        return Paged.fromJson(r.data!, (e) => e);
      });
}
