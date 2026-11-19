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
