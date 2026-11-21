import '../../domain/entities/place_report.dart';
import '../models/place_report_dto.dart';

extension PlaceReportCreateMapper on PlaceReportCreate {
  PlaceReportCreateDto toDto() => PlaceReportCreateDto(
    placeId: placeId,
    reason: reason.value,
    details: details,
    photo: photo,
  );
}

extension PlaceReportResultMapper on PlaceReportResultDto {
  PlaceReportResult toEntity() =>
      PlaceReportResult(id: id, status: status, pointsPending: pointsPending);
}

extension PlaceReportPlaceSummaryMapper on PlaceReportPlaceSummaryDto {
  PlaceReportPlaceSummary toEntity() => PlaceReportPlaceSummary(
    id: id,
    nameEn: nameEn,
    nameAr: nameAr,
    image: image,
  );
}

extension PlaceReportItemMapper on PlaceReportItemDto {
  PlaceReportItem toEntity() => PlaceReportItem(
    id: id,
    place: place.toEntity(),
    reason: PlaceReportReason.fromValue(reason),
    status: status,
    pointsAwarded: pointsAwarded,
    createdAt: createdAt,
  );
}
