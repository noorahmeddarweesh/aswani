/// A place exactly as the API sends it (snake_case JSON).
class PlaceDto {
  const PlaceDto({
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
    required this.image,
    required this.isCurated,
    required this.isEditorsPick,
    required this.isBookmarked,
  });

  factory PlaceDto.fromJson(Map<String, dynamic> json) => PlaceDto(
    id: json['id'] as String,
    category: json['category'] as String,
    nameEn: json['name_en'] as String,
    nameAr: json['name_ar'] as String,
    labelEn: json['label_en'] as String,
    labelAr: json['label_ar'] as String,
    taglineEn: json['tagline_en'] as String,
    taglineAr: json['tagline_ar'] as String,
    cityEn: json['city_en'] as String,
    cityAr: json['city_ar'] as String,
    image: json['image'] as String,
    isCurated: json['is_curated'] as bool? ?? false,
    isEditorsPick: json['is_editors_pick'] as bool? ?? false,
    isBookmarked: json['is_bookmarked'] as bool? ?? false,
  );

  final String id;
  final String category;
  final String nameEn;
  final String nameAr;
  final String labelEn;
  final String labelAr;
  final String taglineEn;
  final String taglineAr;
  final String cityEn;
  final String cityAr;
  final String image;
  final bool isCurated;
  final bool isEditorsPick;
  final bool isBookmarked;
}
