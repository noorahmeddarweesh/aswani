import '../../domain/entities/profile.dart';

// Reads the JSON of the Profile & Settings endpoints (contract v0.2).

Profile profileFromJson(Map<String, dynamic> json) {
  final stats = json['stats'] as Map<String, dynamic>? ?? const {};
  final contributions =
      json['contributions'] as Map<String, dynamic>? ?? const {};
  int n(Map<String, dynamic> m, String key) => (m[key] as num?)?.toInt() ?? 0;
  return Profile(
    id: json['id'] as String,
    fullName: json['full_name'] as String,
    avatar: json['avatar'] as String?,
    persona: json['persona'] as String?,
    city: json['city'] as String?,
    bio: json['bio'] as String?,
    stats: ProfileStats(
      savedPlaces: n(stats, 'saved_places'),
      savedStories: n(stats, 'saved_stories'),
      posts: n(stats, 'posts'),
      points: n(stats, 'points'),
    ),
    savedPreview: [
      for (final e in json['saved_preview'] as List<dynamic>? ?? const [])
        if (SavedType.fromWire((e as Map<String, dynamic>)['type'] as String?)
            case final type?)
          SavedPreview(
            type: type,
            id: e['id'] as String,
            image: e['image'] as String,
          ),
    ].take(3).toList(),
    contributions: ContributionSummary(
      reportsUnderReview: n(contributions, 'reports_under_review'),
      addedActivities: n(contributions, 'added_activities'),
      guideRequestsPending: n(contributions, 'guide_requests_pending'),
    ),
  );
}

/// `{ type, place | story }`, or null for a type this app does not know.
SavedEntry? savedEntryFromJson(Map<String, dynamic> json) {
  switch (SavedType.fromWire(json['type'] as String?)) {
    case SavedType.place:
      final p = json['place'] as Map<String, dynamic>;
      return SavedEntry(
        type: SavedType.place,
        id: p['id'] as String,
        titleEn: p['name_en'] as String,
        titleAr: p['name_ar'] as String,
        labelEn: p['label_en'] as String? ?? '',
        labelAr: p['label_ar'] as String? ?? '',
        image: p['image'] as String,
      );
    case SavedType.story:
      final s = json['story'] as Map<String, dynamic>;
      return SavedEntry(
        type: SavedType.story,
        id: s['id'] as String,
        titleEn: s['title_en'] as String,
        titleAr: s['title_ar'] as String,
        labelEn: s['label_en'] as String? ?? '',
        labelAr: s['label_ar'] as String? ?? '',
        image: s['cover_image'] as String,
      );
    case null:
      return null;
  }
}

UserSettings settingsFromJson(Map<String, dynamic> json) => UserSettings(
  languageCode: json['language'] as String? ?? 'en',
  notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
);
