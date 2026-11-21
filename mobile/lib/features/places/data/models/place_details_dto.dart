import '../models/place_dto.dart';

/// DTO for a single fact in place details.
class PlaceFactDto {
  const PlaceFactDto({
    required this.type,
    required this.labelEn,
    required this.labelAr,
  });

  factory PlaceFactDto.fromJson(Map<String, dynamic> json) => PlaceFactDto(
    type: json['type'] as String,
    labelEn: json['label_en'] as String,
    labelAr: json['label_ar'] as String,
  );

  final String type;
  final String labelEn;
  final String labelAr;

  Map<String, dynamic> toJson() => {
    'type': type,
    'label_en': labelEn,
    'label_ar': labelAr,
  };
}

/// DTO extending Sprint 1 Place without editing PlaceDto.
/// Wraps PlaceDto and holds Sprint 2 fields:
/// location_en/ar, about_en/ar, images[] (up to 6), facts[].
class PlaceDetailsDto {
  const PlaceDetailsDto({
    required this.place,
    required this.locationEn,
    required this.locationAr,
    required this.aboutEn,
    required this.aboutAr,
    required this.images,
    required this.facts,
  });

  factory PlaceDetailsDto.fromJson(Map<String, dynamic> json) {
    return PlaceDetailsDto(
      place: PlaceDto.fromJson(json),
      locationEn: json['location_en'] as String? ?? '',
      locationAr: json['location_ar'] as String? ?? '',
      aboutEn: json['about_en'] as String? ?? '',
      aboutAr: json['about_ar'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      facts: (json['facts'] as List<dynamic>?)
              ?.map((e) => PlaceFactDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  final PlaceDto place;
  final String locationEn;
  final String locationAr;
  final String aboutEn;
  final String aboutAr;
  final List<String> images;
  final List<PlaceFactDto> facts;

  Map<String, dynamic> toJson() => {
    'id': place.id,
    'category': place.category,
    'name_en': place.nameEn,
    'name_ar': place.nameAr,
    'label_en': place.labelEn,
    'label_ar': place.labelAr,
    'tagline_en': place.taglineEn,
    'tagline_ar': place.taglineAr,
    'city_en': place.cityEn,
    'city_ar': place.cityAr,
    'image': place.image,
    'is_curated': place.isCurated,
    'is_editors_pick': place.isEditorsPick,
    'is_bookmarked': place.isBookmarked,
    'location_en': locationEn,
    'location_ar': locationAr,
    'about_en': aboutEn,
    'about_ar': aboutAr,
    'images': images,
    'facts': facts.map((f) => f.toJson()).toList(),
  };
}
