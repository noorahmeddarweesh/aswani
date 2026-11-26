/// JSON shapes of contract v0.2, Culture (snake_case).
class StorySummaryDto {
  const StorySummaryDto(this.json);

  final Map<String, dynamic> json;

  String get id => json['id'] as String;
  String get theme => json['theme'] as String;
  String get titleEn => json['title_en'] as String;
  String get titleAr => json['title_ar'] as String;
  String get labelEn => json['label_en'] as String? ?? '';
  String get labelAr => json['label_ar'] as String? ?? '';
  String? get locationEn => json['location_en'] as String?;
  String? get locationAr => json['location_ar'] as String?;
  String get coverImage => json['cover_image'] as String;
  int get readMinutes => json['read_minutes'] as int? ?? 1;
  bool get isSample => json['is_sample'] as bool? ?? false;
  bool get isSaved => json['is_saved'] as bool? ?? false;
}

class StoryBlockDto {
  const StoryBlockDto(this.json);

  final Map<String, dynamic> json;

  String get type => json['type'] as String;
  String get textEn => json['text_en'] as String? ?? '';
  String get textAr => json['text_ar'] as String? ?? '';
  String? get image => json['image'] as String?;
  String? get captionEn => json['caption_en'] as String?;
  String? get captionAr => json['caption_ar'] as String?;
}

class ThemeDto {
  const ThemeDto(this.json);

  final Map<String, dynamic> json;

  String get id => json['id'] as String;
  String get titleEn => json['title_en'] as String;
  String get titleAr => json['title_ar'] as String;
  String get image => json['image'] as String;
}
