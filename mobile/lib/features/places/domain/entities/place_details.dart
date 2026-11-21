import 'place.dart';

/// One fact about a place (access type or visiting hours).
class PlaceFact {
  const PlaceFact({
    required this.type,
    required this.labelEn,
    required this.labelAr,
  });

  /// 'access' | 'hours'
  final String type;
  final String labelEn;
  final String labelAr;

  String label(String languageCode) =>
      languageCode == 'ar' ? labelAr : labelEn;
}

/// Place details entity extending Sprint 1 Place without modifying it.
/// Wraps the existing Place entity and adds Sprint 2 fields:
/// location_en/ar, about_en/ar, images[] (up to 6), facts[].
class PlaceDetails {
  const PlaceDetails({
    required this.place,
    required this.locationEn,
    required this.locationAr,
    required this.aboutEn,
    required this.aboutAr,
    required this.images,
    required this.facts,
  });

  /// The wrapped Sprint 1 Place entity.
  final Place place;

  final String locationEn;
  final String locationAr;
  final String aboutEn;
  final String aboutAr;
  final List<String> images;
  final List<PlaceFact> facts;

  // Convenient forwarders to the wrapped place
  String get id => place.id;
  PlaceCategory get category => place.category;
  String get nameEn => place.nameEn;
  String get nameAr => place.nameAr;
  String get labelEn => place.labelEn;
  String get labelAr => place.labelAr;
  String get taglineEn => place.taglineEn;
  String get taglineAr => place.taglineAr;
  String get cityEn => place.cityEn;
  String get cityAr => place.cityAr;
  String get imagePath => place.imagePath;
  bool get isCurated => place.isCurated;
  bool get isEditorsPick => place.isEditorsPick;
  bool get isBookmarked => place.isBookmarked;

  String name(String languageCode) => place.name(languageCode);
  String label(String languageCode) => place.label(languageCode);
  String tagline(String languageCode) => place.tagline(languageCode);
  String city(String languageCode) => place.city(languageCode);
  String location(String languageCode) =>
      languageCode == 'ar' ? locationAr : locationEn;
  String about(String languageCode) =>
      languageCode == 'ar' ? aboutAr : aboutEn;
}
