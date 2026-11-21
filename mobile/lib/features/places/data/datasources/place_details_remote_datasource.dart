import 'dart:io';

import 'package:aswani/core/network/api_client.dart';
import 'package:aswani/features/local_guides/data/models/page_meta_dto.dart';
import 'package:dio/dio.dart';

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
  Future<PlaceReportResultDto> createPlaceReport(
    PlaceReportCreateDto report,
  ) => apiCall(() async {
    final formData = FormData();
    formData.fields.add(MapEntry('place_id', report.placeId));
    formData.fields.add(MapEntry('reason', report.reason));
    formData.fields.add(MapEntry('details', report.details));

    if (report.photo != null && report.photo!.isNotEmpty) {
      final photoPath = report.photo!;
      final file = File(photoPath);
      final filename = photoPath.split(RegExp(r'[\\/]')).last;
      if (file.existsSync()) {
        formData.files.add(
          MapEntry(
            'photo',
            await MultipartFile.fromFile(photoPath, filename: filename),
          ),
        );
      } else {
        formData.files.add(
          MapEntry(
            'photo',
            MultipartFile.fromString(photoPath, filename: filename),
          ),
        );
      }
    }

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
