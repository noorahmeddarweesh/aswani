import '../models/place_dto.dart';

abstract interface class PlacesDataSource {
  /// GET /api/places?category=
  Future<List<PlaceDto>> getPlaces({String? category});

  /// GET /api/places/curated
  Future<List<PlaceDto>> getCurated();

  /// POST /api/bookmarks when [saved], DELETE /api/bookmarks/{id} when not.
  /// Returns the place with its new `is_bookmarked`.
  Future<PlaceDto> setBookmark(String placeId, {required bool saved});
}
