import '../models/place_dto.dart';

abstract interface class PlacesDataSource {
  /// GET /api/places?category=
  Future<List<PlaceDto>> getPlaces({String? category});

  /// GET /api/places/curated
  Future<List<PlaceDto>> getCurated();

  /// POST /api/bookmarks (add) or DELETE /api/bookmarks/{id} (remove).
  Future<PlaceDto> toggleBookmark(String placeId);
}
