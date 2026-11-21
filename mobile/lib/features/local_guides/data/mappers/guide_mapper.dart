import '../../domain/entities/guide.dart';
import '../../domain/entities/guide_enums.dart';
import '../../domain/entities/page_meta.dart';
import '../models/guide_dto.dart';
import '../models/page_meta_dto.dart';

extension GuideMapper on GuideDto {
  Guide toEntity() => Guide(
    id: id,
    fullName: fullName,
    photo: photo,
    city: city,
    tagline: tagline,
    languages: languages.map(GuideLanguage.fromValue).toList(),
    specialties: specialties.map(GuideSpecialty.fromValue).toList(),
    bio: bio,
    durations: durations.map(GuideDuration.fromValue).toList(),
    isFeatured: isFeatured,
    isVerified: isVerified,
  );
}

extension GuideSummaryMapper on GuideSummaryDto {
  GuideSummary toEntity() =>
      GuideSummary(id: id, fullName: fullName, photo: photo);
}

extension PageMetaMapper on PageMetaDto {
  PageMeta toEntity() =>
      PageMeta(page: page, limit: limit, total: total, totalPages: totalPages);
}
