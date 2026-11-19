import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/place_dto.dart';
import 'places_datasource.dart';

/// Places and bookmarks endpoints of the real API
/// (contract: Places and bookmarks section).
class PlacesRemoteDataSource implements PlacesDataSource {
  PlacesRemoteDataSource(this._client);

  final Dio _client;

  /// Sprint 1 shows one page; paging comes with longer lists.
  static const int pageSize = 50;

  @override
  Future<List<PlaceDto>> getPlaces({String? category}) => apiCall(() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/places',
      queryParameters: {'category': ?category, 'page': 1, 'limit': pageSize},
    );
    return _list(response.data!);
  });

  @override
  Future<List<PlaceDto>> getCurated() => apiCall(() async {
    final response = await _client.get<Map<String, dynamic>>('/places/curated');
    return _list(response.data!);
  });

  @override
  Future<PlaceDto> setBookmark(String placeId, {required bool saved}) =>
      apiCall(() async {
        final response = saved
            ? await _client.post<Map<String, dynamic>>(
                '/bookmarks',
                data: {'place_id': placeId},
              )
            : await _client.delete<Map<String, dynamic>>(
                '/bookmarks/${Uri.encodeComponent(placeId)}',
              );
        return PlaceDto.fromJson(
          response.data!['data'] as Map<String, dynamic>,
        );
      });

  List<PlaceDto> _list(Map<String, dynamic> body) => [
    for (final item in body['data'] as List<dynamic>)
      PlaceDto.fromJson(item as Map<String, dynamic>),
  ];
}
