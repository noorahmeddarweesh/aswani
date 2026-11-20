/// The signed-in user's profile screen, loaded in one call
/// (GET /api/users/me/profile).
class Profile {
  const Profile({
    required this.id,
    required this.fullName,
    required this.stats,
    required this.savedPreview,
    required this.contributions,
    this.avatar,
    this.persona,
    this.city,
    this.bio,
  });

  final String id;
  final String fullName;

  /// Photo URL (asset path in mocks), or null: the app shows the first letter.
  final String? avatar;

  /// Persona value from personalisation (e.g. `newcomer`), or null.
  final String? persona;
  final String? city;
  final String? bio;
  final ProfileStats stats;

  /// Up to 3 photos under "My saved content".
  final List<SavedPreview> savedPreview;
  final ContributionSummary contributions;

  Profile copyWith({String? avatar}) => Profile(
    id: id,
    fullName: fullName,
    avatar: avatar ?? this.avatar,
    persona: persona,
    city: city,
    bio: bio,
    stats: stats,
    savedPreview: savedPreview,
    contributions: contributions,
  );
}

class ProfileStats {
  const ProfileStats({
    required this.savedPlaces,
    required this.savedStories,
    required this.posts,
    required this.points,
  });

  final int savedPlaces;
  final int savedStories;
  final int posts;

  /// Sum of `points_awarded` on accepted reports and contributions.
  final int points;
}

/// The rows under "My contributions".
class ContributionSummary {
  const ContributionSummary({
    required this.reportsUnderReview,
    required this.addedActivities,
    required this.guideRequestsPending,
  });

  final int reportsUnderReview;
  final int addedActivities;
  final int guideRequestsPending;
}

enum SavedType {
  place('place'),
  story('story');

  const SavedType(this.wire);
  final String wire;

  static SavedType? fromWire(String? value) =>
      values.where((t) => t.wire == value).firstOrNull;
}

class SavedPreview {
  const SavedPreview({
    required this.type,
    required this.id,
    required this.image,
  });

  final SavedType type;
  final String id;
  final String image;
}

/// One row of "My saved content" (GET /api/saved): a place or a story.
class SavedEntry {
  const SavedEntry({
    required this.type,
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.labelEn,
    required this.labelAr,
    required this.image,
  });

  final SavedType type;
  final String id;
  final String titleEn;
  final String titleAr;
  final String labelEn;
  final String labelAr;
  final String image;

  String title(String languageCode) => languageCode == 'ar' ? titleAr : titleEn;
  String label(String languageCode) => languageCode == 'ar' ? labelAr : labelEn;
}

/// GET / PATCH /api/users/settings.
class UserSettings {
  const UserSettings({
    required this.languageCode,
    required this.notificationsEnabled,
  });

  final String languageCode;
  final bool notificationsEnabled;

  UserSettings copyWith({String? languageCode, bool? notificationsEnabled}) =>
      UserSettings(
        languageCode: languageCode ?? this.languageCode,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      );
}
