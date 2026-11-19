/// A signed-in user, as the app sees it (camelCase, immutable).
class User {
  const User({
    required this.id,
    required this.fullName,
    required this.identifier,
    this.hasPreferences = false,
    this.avatarUrl,
  });

  final String id;
  final String fullName;

  /// Email or phone the user signs in with.
  final String identifier;

  /// True once the user finished the personalisation steps.
  final bool hasPreferences;

  /// Profile photo, or null to show the initial.
  final String? avatarUrl;

  String get firstName => fullName.trim().split(' ').first;
}
