/// Body of `PUT /api/users/preferences`, exactly as the API expects it.
class PreferencesDto {
  const PreferencesDto({
    required this.persona,
    required this.purpose,
    required this.stayLength,
    required this.interests,
    required this.travelStyles,
    required this.companions,
    required this.needs,
    required this.language,
  });

  factory PreferencesDto.fromJson(Map<String, dynamic> json) {
    List<String> list(String key) =>
        (json[key] as List<dynamic>? ?? const []).cast<String>();
    return PreferencesDto(
      persona: json['persona'] as String?,
      purpose: json['purpose'] as String?,
      stayLength: json['stay_length'] as String?,
      interests: list('interests'),
      travelStyles: list('travel_styles'),
      companions: json['companions'] as String?,
      needs: list('needs'),
      language: json['language'] as String? ?? 'en',
    );
  }

  final String? persona;
  final String? purpose;
  final String? stayLength;
  final List<String> interests;
  final List<String> travelStyles;
  final String? companions;
  final List<String> needs;
  final String language;

  Map<String, dynamic> toJson() => {
    'persona': persona,
    'purpose': purpose,
    'stay_length': stayLength,
    'interests': interests,
    'travel_styles': travelStyles,
    'companions': companions,
    'needs': needs,
    'language': language,
  };
}
