import '../../../../core/assets/app_images.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../models/place_dto.dart';
import 'places_datasource.dart';

/// In-memory places, in the API's list shape `{ "data": [...], "meta": {...} }`.
class PlacesMockDataSource implements PlacesDataSource {
  PlacesMockDataSource({this.delay = const Duration(milliseconds: 500)});

  final Duration delay;
  final Set<String> _bookmarks = {};

  static const List<Map<String, dynamic>> _seed = [
    {
      'id': 'philae',
      'category': 'history',
      'name_en': 'Philae Temple',
      'name_ar': 'معبد فيلة',
      'label_en': 'Heritage & history',
      'label_ar': 'تراث وتاريخ',
      'tagline_en': 'History on an island',
      'tagline_ar': 'تاريخ على جزيرة',
      'city_en': 'Aswan',
      'city_ar': 'أسوان',
      'image': AppImages.philaeTemple,
      'is_curated': true,
      'is_editors_pick': true,
    },
    {
      'id': 'nubian-village',
      'category': 'nubian',
      'name_en': 'Nubian Village',
      'name_ar': 'القرية النوبية',
      'label_en': 'Local culture',
      'label_ar': 'ثقافة محلية',
      'tagline_en': 'Colours, music and hospitality',
      'tagline_ar': 'ألوان وموسيقى وكرم ضيافة',
      'city_en': 'Aswan',
      'city_ar': 'أسوان',
      'image': AppImages.nubianVillage,
      'is_curated': true,
    },
    {
      'id': 'elephantine',
      'category': 'nature',
      'name_en': 'Elephantine Island',
      'name_ar': 'جزيرة إلفنتين',
      'label_en': 'Nature & local life',
      'label_ar': 'طبيعة وحياة محلية',
      'tagline_en': 'Nile & local life',
      'tagline_ar': 'النيل والحياة المحلية',
      'city_en': 'Aswan',
      'city_ar': 'أسوان',
      'image': AppImages.elephantineIsland,
      'is_curated': true,
    },
    {
      'id': 'nubian-museum',
      'category': 'history',
      'name_en': 'Nubian Museum',
      'name_ar': 'متحف النوبة',
      'label_en': 'Heritage & history',
      'label_ar': 'تراث وتاريخ',
      'tagline_en': 'The story of Nubia',
      'tagline_ar': 'حكاية النوبة',
      'city_en': 'Aswan',
      'city_ar': 'أسوان',
      'image': AppImages.nubianMuseum,
    },
  ];

  PlaceDto _dto(Map<String, dynamic> json) => PlaceDto.fromJson({
    ...json,
    'is_bookmarked': _bookmarks.contains(json['id']),
  });

  @override
  Future<List<PlaceDto>> getPlaces({String? category}) async {
    await Future<void>.delayed(delay);
    return _seed
        .where((p) => category == null || p['category'] == category)
        .map(_dto)
        .toList();
  }

  @override
  Future<List<PlaceDto>> getCurated() async {
    await Future<void>.delayed(delay);
    // Home shows the curated places in the editors' order.
    const order = ['philae', 'elephantine', 'nubian-village'];
    return [
      for (final id in order) _dto(_seed.firstWhere((p) => p['id'] == id)),
    ];
  }

  @override
  Future<PlaceDto> setBookmark(String placeId, {required bool saved}) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final json = _seed.where((p) => p['id'] == placeId).firstOrNull;
    if (json == null) {
      throw const AppException(code: ErrorCodes.placeNotFound, statusCode: 404);
    }
    saved ? _bookmarks.add(placeId) : _bookmarks.remove(placeId);
    return _dto(json);
  }
}
