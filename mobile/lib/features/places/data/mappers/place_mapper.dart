import '../../domain/entities/place.dart';
import '../models/place_dto.dart';

extension PlaceMapper on PlaceDto {
  Place toEntity() => Place(
    id: id,
    category: PlaceCategory.values.firstWhere(
      (c) => c.name == category,
      orElse: () => PlaceCategory.history,
    ),
    nameEn: nameEn,
    nameAr: nameAr,
    labelEn: labelEn,
    labelAr: labelAr,
    taglineEn: taglineEn,
    taglineAr: taglineAr,
    cityEn: cityEn,
    cityAr: cityAr,
    // The mock sends asset paths; the real API will send image URLs.
    imagePath: image,
    isCurated: isCurated,
    isEditorsPick: isEditorsPick,
    isBookmarked: isBookmarked,
  );
}
