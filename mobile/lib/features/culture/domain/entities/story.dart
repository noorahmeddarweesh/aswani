/// Culture themes (contract v0.2, Culture).
enum CultureTheme {
  nubianHeritage('nubian_heritage'),
  ancientHistory('ancient_history'),
  traditions('traditions'),
  artsCrafts('arts_crafts');

  const CultureTheme(this.wire);

  final String wire;

  static CultureTheme? fromWire(String? value) =>
      CultureTheme.values.where((t) => t.wire == value).firstOrNull;
}

/// Picks the text of the app's language.
String pick(String languageCode, String en, String ar) =>
    languageCode == 'ar' ? ar : en;

/// A story as shown in cards and lists.
class StorySummary {
  const StorySummary({
    required this.id,
    required this.theme,
    required this.titleEn,
    required this.titleAr,
    required this.labelEn,
    required this.labelAr,
    required this.coverImage,
    required this.readMinutes,
    required this.isSample,
    required this.isSaved,
    this.locationEn,
    this.locationAr,
  });

  final String id;
  final CultureTheme theme;
  final String titleEn;
  final String titleAr;
  final String labelEn;
  final String labelAr;
  final String? locationEn;
  final String? locationAr;
  final String coverImage;
  final int readMinutes;
  final bool isSample;
  final bool isSaved;

  String title(String lang) => pick(lang, titleEn, titleAr);
  String label(String lang) => pick(lang, labelEn, labelAr);
  String? location(String lang) =>
      locationEn == null ? null : pick(lang, locationEn!, locationAr ?? '');

  StorySummary copyWith({bool? isSaved}) => StorySummary(
    id: id,
    theme: theme,
    titleEn: titleEn,
    titleAr: titleAr,
    labelEn: labelEn,
    labelAr: labelAr,
    locationEn: locationEn,
    locationAr: locationAr,
    coverImage: coverImage,
    readMinutes: readMinutes,
    isSample: isSample,
    isSaved: isSaved ?? this.isSaved,
  );
}

enum StoryBlockType { lead, paragraph, heading, quote, image }

/// One piece of a story, drawn in order.
class StoryBlock {
  const StoryBlock({
    required this.type,
    this.textEn = '',
    this.textAr = '',
    this.image,
    this.captionEn,
    this.captionAr,
  });

  final StoryBlockType type;
  final String textEn;
  final String textAr;
  final String? image;
  final String? captionEn;
  final String? captionAr;

  String text(String lang) => pick(lang, textEn, textAr);
  String? caption(String lang) =>
      captionEn == null ? null : pick(lang, captionEn!, captionAr ?? '');
}

class Story {
  const Story({required this.summary, required this.blocks});

  final StorySummary summary;
  final List<StoryBlock> blocks;

  Story copyWith({StorySummary? summary}) =>
      Story(summary: summary ?? this.summary, blocks: blocks);
}

/// A tile of "Browse by theme".
class ThemeInfo {
  const ThemeInfo({
    required this.theme,
    required this.titleEn,
    required this.titleAr,
    required this.image,
  });

  final CultureTheme theme;
  final String titleEn;
  final String titleAr;
  final String image;

  String title(String lang) => pick(lang, titleEn, titleAr);
}

/// Everything Culture home shows, from one call.
class CultureHome {
  const CultureHome({
    required this.featured,
    required this.themes,
    required this.selectedReads,
  });

  final StorySummary featured;
  final List<ThemeInfo> themes;
  final List<StorySummary> selectedReads;

  CultureHome mapStories(StorySummary Function(StorySummary) change) =>
      CultureHome(
        featured: change(featured),
        themes: themes,
        selectedReads: selectedReads.map(change).toList(),
      );
}
