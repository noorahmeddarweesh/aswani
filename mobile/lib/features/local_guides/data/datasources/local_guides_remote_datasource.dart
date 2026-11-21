import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/guide_application_dto.dart';
import '../models/guide_dto.dart';
import '../models/guide_request_dto.dart';
import '../models/page_meta_dto.dart';
import 'local_guides_datasource.dart';

/// Remote datasource implementation for Local Guides per API Contract v0.2.
/// Communicates with real backend endpoints via Dio and handles
/// query parameters, response wrappers, multipart form-data, and API exceptions.
class LocalGuidesRemoteDataSource implements LocalGuidesDataSource {
  LocalGuidesRemoteDataSource(this._client);

  final Dio _client;

  @override
  Future<PagedListDto<GuideDto>> getGuides({
    String? specialty,
    String? q,
    int page = 1,
    int limit = 20,
  }) => apiCall(() async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (specialty != null && specialty.isNotEmpty) {
      query['specialty'] = specialty;
    }
    if (q != null && q.isNotEmpty) {
      query['q'] = q;
    }

    final response = await _client.get<Map<String, dynamic>>(
      '/guides',
      queryParameters: query,
    );

    final body = response.data!;
    final items = [
      for (final item in body['data'] as List<dynamic>)
        GuideDto.fromJson(item as Map<String, dynamic>),
    ];
    final meta = PageMetaDto.fromJson(body['meta'] as Map<String, dynamic>);
    return PagedListDto<GuideDto>(data: items, meta: meta);
  });

  @override
  Future<GuideDto> getGuide(String id) => apiCall(() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/guides/${Uri.encodeComponent(id)}',
    );
    return GuideDto.fromJson(response.data!['data'] as Map<String, dynamic>);
  });

  @override
  Future<GuideRequestResultDto> createGuideRequest(
    GuideRequestCreateDto request,
  ) => apiCall(() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/guide-requests',
      data: request.toJson(),
    );
    return GuideRequestResultDto.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  });

  @override
  Future<PagedListDto<GuideRequestItemDto>> getGuideRequestsMine({
    int page = 1,
    int limit = 20,
  }) => apiCall(() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/guide-requests/mine',
      queryParameters: {'page': page, 'limit': limit},
    );
    final body = response.data!;
    final items = [
      for (final item in body['data'] as List<dynamic>)
        GuideRequestItemDto.fromJson(item as Map<String, dynamic>),
    ];
    final meta = PageMetaDto.fromJson(body['meta'] as Map<String, dynamic>);
    return PagedListDto<GuideRequestItemDto>(data: items, meta: meta);
  });

  @override
  Future<GuideApplicationResultDto> createGuideApplication(
    GuideApplicationCreateDto application,
  ) => apiCall(() async {
    final formData = FormData();
    formData.fields.add(MapEntry('full_name', application.fullName));
    formData.fields.add(MapEntry('bio', application.bio));
    formData.fields.add(MapEntry('contact', application.contact));

    for (final lang in application.languages) {
      formData.fields.add(MapEntry('languages', lang));
    }
    for (final spec in application.specialties) {
      formData.fields.add(MapEntry('specialties', spec));
    }
    for (final dur in application.durations) {
      formData.fields.add(MapEntry('durations', dur));
    }

    if (application.profilePhoto != null &&
        application.profilePhoto!.isNotEmpty) {
      final photoPath = application.profilePhoto!;
      final file = File(photoPath);
      final filename = photoPath.split(RegExp(r'[\\/]')).last;
      if (file.existsSync()) {
        formData.files.add(
          MapEntry(
            'profile_photo',
            await MultipartFile.fromFile(photoPath, filename: filename),
          ),
        );
      } else {
        formData.files.add(
          MapEntry(
            'profile_photo',
            MultipartFile.fromString(photoPath, filename: filename),
          ),
        );
      }
    }

    final response = await _client.post<Map<String, dynamic>>(
      '/guide-applications',
      data: formData,
    );

    return GuideApplicationResultDto.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  });
}
