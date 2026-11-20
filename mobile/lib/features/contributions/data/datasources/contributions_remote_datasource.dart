import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/upload.dart';
import '../../../../core/pagination/paged.dart';
import 'contributions_datasource.dart';

/// Contribution endpoints of the real API (contract v0.2, Contribute).
class ContributionsRemoteDataSource implements ContributionsDataSource {
  ContributionsRemoteDataSource(this._client);

  final Dio _client;

  @override
  Future<Map<String, dynamic>> submit(
    Map<String, Object?> fields,
    List<UploadFile> photos,
  ) => apiCall(() async {
    final r = await _client.post<Map<String, dynamic>>(
      '/contributions',
      data: buildFormData(fields: fields, filesField: 'photos', files: photos),
    );
    return r.data!['data'] as Map<String, dynamic>;
  });

  @override
  Future<Map<String, dynamic>> getOne(String id) => apiCall(() async {
    final r = await _client.get<Map<String, dynamic>>('/contributions/$id');
    return r.data!['data'] as Map<String, dynamic>;
  });

  @override
  Future<Map<String, dynamic>> update(
    String id,
    Map<String, Object?> fields,
    List<UploadFile> photos,
  ) => apiCall(() async {
    final r = await _client.patch<Map<String, dynamic>>(
      '/contributions/$id',
      data: buildFormData(fields: fields, filesField: 'photos', files: photos),
    );
    return r.data!['data'] as Map<String, dynamic>;
  });

  @override
  Future<Paged<Map<String, dynamic>>> getMine({int page = 1}) =>
      apiCall(() async {
        final r = await _client.get<Map<String, dynamic>>(
          '/contributions/mine',
          queryParameters: {'page': page, 'limit': kPageSize},
        );
        return Paged.fromJson(r.data!, (e) => e);
      });
}
