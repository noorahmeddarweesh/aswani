import '../../domain/entities/guide_enums.dart';
import '../../domain/entities/guide_request.dart';
import '../models/guide_request_dto.dart';
import 'guide_mapper.dart';

extension GuideRequestCreateMapper on GuideRequestCreate {
  GuideRequestCreateDto toDto() => GuideRequestCreateDto(
    guideId: guideId,
    date: date,
    duration: duration.value,
    durationHours: durationHours,
    startTime: startTime,
    groupSize: groupSize,
    language: language.value,
    interests: interests.isNotEmpty ? interests.map((e) => e.value).toList() : null,
    notes: notes,
  );
}

extension GuideRequestResultMapper on GuideRequestResultDto {
  GuideRequestResult toEntity() => GuideRequestResult(
    id: id,
    status: RequestStatus.fromValue(status),
  );
}

extension GuideRequestItemMapper on GuideRequestItemDto {
  GuideRequestItem toEntity() => GuideRequestItem(
    id: id,
    guide: guide.toEntity(),
    date: date,
    duration: RequestDuration.fromValue(duration),
    durationHours: durationHours,
    startTime: startTime,
    groupSize: groupSize,
    language: GuideLanguage.fromValue(language),
    interests: interests.map(GuideSpecialty.fromValue).toList(),
    status: RequestStatus.fromValue(status),
    createdAt: createdAt,
  );
}
