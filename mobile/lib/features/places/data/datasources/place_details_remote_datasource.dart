import 'package:aswani/core/network/api_client.dart';
import 'package:aswani/features/local_guides/data/models/page_meta_dto.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/upload.dart';
import '../models/place_details_dto.dart';
import '../models/place_report_dto.dart';
import 'place_details_datasource.dart';

/// Remote datasource implementation for Place Details and Place Reports per API Contract v0.2.
class PlaceDetailsRemoteDataSource implements PlaceDetailsDataSource {
  PlaceDetailsRemoteDataSource(this._client);

  final Dio _client;

  @override
  Future<PlaceDetailsDto> getPlaceDetails(String id) => apiCall(() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/places/${Uri.encodeComponent(id)}',
    );
    return PlaceDetailsDto.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  });

  @override
  Future<PlaceReportResultDto> createPlaceReport(PlaceReportCreateDto report) =>
      apiCall(() async {
        // Bytes, not a file path, so it works on the web too.
        final formData = buildFormData(
          fields: {
            'place_id': report.placeId,
            'reason': report.reason,
            'details': report.details,
          },
          filesField: 'photo',
          files: [?report.photo],
        );
        final response = await _client.post<Map<String, dynamic>>(
          '/place-reports',
          data: formData,
        );

        return PlaceReportResultDto.fromJson(
          response.data!['data'] as Map<String, dynamic>,
        );
      });

  @override
  Future<PagedListDto<PlaceReportItemDto>> getPlaceReportsMine({
    int page = 1,
    int limit = 20,
  }) => apiCall(() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/place-reports/mine',
      queryParameters: {'page': page, 'limit': limit},
    );

    final body = response.data!;
    final items = [
      for (final item in body['data'] as List<dynamic>)
        PlaceReportItemDto.fromJson(item as Map<String, dynamic>),
    ];
    final meta = PageMetaDto.fromJson(body['meta'] as Map<String, dynamic>);
    return PagedListDto<PlaceReportItemDto>(data: items, meta: meta);
  });
}
