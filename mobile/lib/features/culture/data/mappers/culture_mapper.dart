import '../../domain/entities/story.dart';
import '../models/culture_dtos.dart';

extension StorySummaryMapper on StorySummaryDto {
  StorySummary toEntity() => StorySummary(
    id: id,
    theme: CultureTheme.fromWire(theme) ?? CultureTheme.traditions,
    titleEn: titleEn,
    titleAr: titleAr,
    labelEn: labelEn,
    labelAr: labelAr,
    locationEn: locationEn,
    locationAr: locationAr,
    coverImage: coverImage,
    readMinutes: readMinutes,
    isSample: isSample,
    isSaved: isSaved,
  );

  Story toStory() => Story(
    summary: toEntity(),
    blocks: [
      for (final b in json['blocks'] as List<dynamic>? ?? const [])
        StoryBlockDto(b as Map<String, dynamic>).toEntity(),
    ],
  );
}

extension StoryBlockMapper on StoryBlockDto {
  StoryBlock toEntity() => StoryBlock(
    type: StoryBlockType.values.firstWhere(
      (t) => t.name == type,
      orElse: () => StoryBlockType.paragraph,
    ),
    textEn: textEn,
    textAr: textAr,
    image: image,
    captionEn: captionEn,
    captionAr: captionAr,
  );
}

extension ThemeMapper on ThemeDto {
  ThemeInfo? toEntity() {
    final theme = CultureTheme.fromWire(id);
    if (theme == null) return null;
    return ThemeInfo(
      theme: theme,
      titleEn: titleEn,
      titleAr: titleAr,
      image: image,
    );
  }
}

CultureHome cultureHomeFromJson(Map<String, dynamic> data) => CultureHome(
  featured: StorySummaryDto(data['featured'] as Map<String, dynamic>)
      .toEntity(),
  themes: [
    for (final t in data['themes'] as List<dynamic>)
      ?ThemeDto(t as Map<String, dynamic>).toEntity(),
  ],
  selectedReads: [
    for (final s in data['selected_reads'] as List<dynamic>)
      StorySummaryDto(s as Map<String, dynamic>).toEntity(),
  ],
);
