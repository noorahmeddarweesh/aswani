/// User exactly as the API sends it (snake_case JSON).
class UserDto {
  const UserDto({
    required this.id,
    required this.fullName,
    required this.identifier,
    this.hasPreferences = false,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
    id: json['id'] as String,
    fullName: json['full_name'] as String,
    identifier: json['identifier'] as String,
    hasPreferences: json['has_preferences'] as bool? ?? false,
  );

  final String id;
  final String fullName;
  final String identifier;
  final bool hasPreferences;

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'identifier': identifier,
    'has_preferences': hasPreferences,
  };
}
