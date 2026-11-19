/// User exactly as the API sends it (snake_case JSON).
class UserDto {
  const UserDto({
    required this.id,
    required this.fullName,
    required this.identifier,
    this.hasPreferences = false,
    this.avatarUrl,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
    id: json['id'] as String,
    fullName: json['full_name'] as String,
    identifier: json['identifier'] as String,
    hasPreferences: json['has_preferences'] as bool? ?? false,
    avatarUrl: json['avatar_url'] as String?,
  );

  final String id;
  final String fullName;
  final String identifier;
  final bool hasPreferences;
  final String? avatarUrl;

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'identifier': identifier,
    'has_preferences': hasPreferences,
    'avatar_url': avatarUrl,
  };
}
