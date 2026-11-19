import '../../../../core/result/result.dart';
import '../entities/place.dart';

abstract interface class PlacesRepository {
  /// All places, optionally of one category.
  Future<Result<List<Place>>> getPlaces({PlaceCategory? category});

  /// Places picked for the user (home "Curated for you").
  Future<Result<List<Place>>> getCurated();

  /// Saves ([saved] true) or un-saves a place; returns the updated place.
  Future<Result<Place>> setBookmark(String placeId, {required bool saved});
}
