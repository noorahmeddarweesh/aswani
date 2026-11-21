import '../../domain/entities/guide_application.dart';
import '../../domain/entities/guide_enums.dart';
import '../models/guide_application_dto.dart';

extension GuideApplicationCreateMapper on GuideApplicationCreate {
  GuideApplicationCreateDto toDto() => GuideApplicationCreateDto(
    fullName: fullName,
    languages: languages.map((e) => e.value).toList(),
    specialties: specialties.map((e) => e.value).toList(),
    bio: bio,
    durations: durations.map((e) => e.value).toList(),
    contact: contact,
    profilePhoto: profilePhoto,
  );
}

extension GuideApplicationResultMapper on GuideApplicationResultDto {
  GuideApplicationResult toEntity() => GuideApplicationResult(
    id: id,
    status: RequestStatus.fromValue(status),
  );
}
