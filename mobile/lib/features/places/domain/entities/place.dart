enum PlaceCategory { history, nubian, nature, food }

/// A point of interest. Names come from the API in both languages
/// (`name_en` / `name_ar` in the class diagram); the screen picks one.
class Place {
  const Place({
    required this.id,
    required this.category,
    required this.nameEn,
    required this.nameAr,
    required this.labelEn,
    required this.labelAr,
    required this.taglineEn,
    required this.taglineAr,
    required this.cityEn,
    required this.cityAr,
    required this.imagePath,
    this.isCurated = false,
    this.isEditorsPick = false,
    this.isBookmarked = false,
  });

  final String id;
  final PlaceCategory category;
  final String nameEn;
  final String nameAr;

  /// Short category line, e.g. "Heritage & history".
  final String labelEn;
  final String labelAr;
  final String taglineEn;
  final String taglineAr;
  final String cityEn;
  final String cityAr;
  final String imagePath;
  final bool isCurated;
  final bool isEditorsPick;
  final bool isBookmarked;

  String name(String languageCode) => languageCode == 'ar' ? nameAr : nameEn;
  String label(String languageCode) => languageCode == 'ar' ? labelAr : labelEn;
  String tagline(String languageCode) =>
      languageCode == 'ar' ? taglineAr : taglineEn;
  String city(String languageCode) => languageCode == 'ar' ? cityAr : cityEn;
}
