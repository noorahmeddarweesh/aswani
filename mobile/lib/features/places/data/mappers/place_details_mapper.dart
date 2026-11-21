import '../../domain/entities/place_details.dart';
import '../models/place_details_dto.dart';
import 'place_mapper.dart';

extension PlaceFactMapper on PlaceFactDto {
  PlaceFact toEntity() => PlaceFact(
    type: type,
    labelEn: labelEn,
    labelAr: labelAr,
  );
}

extension PlaceDetailsMapper on PlaceDetailsDto {
  PlaceDetails toEntity() => PlaceDetails(
    place: place.toEntity(),
    locationEn: locationEn,
    locationAr: locationAr,
    aboutEn: aboutEn,
    aboutAr: aboutAr,
    images: images,
    facts: facts.map((f) => f.toEntity()).toList(),
  );
}
