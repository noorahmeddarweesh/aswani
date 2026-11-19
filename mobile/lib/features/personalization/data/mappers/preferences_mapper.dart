import '../../domain/entities/preferences.dart';
import '../models/preferences_dto.dart';

/// camelCase enum name -> snake_case API value, e.g. fewDays -> few_days.
String _snake(Enum value) => value.name.replaceAllMapped(
  RegExp('[A-Z]'),
  (m) => '_${m.group(0)!.toLowerCase()}',
);

extension PreferencesMapper on Preferences {
  PreferencesDto toDto() => PreferencesDto(
    persona: persona == null ? null : _snake(persona!),
    purpose: purpose == null ? null : _snake(purpose!),
    stayLength: stayLength == null ? null : _snake(stayLength!),
    interests: interests.map(_snake).toList(),
    travelStyles: styles.map(_snake).toList(),
    companions: companions == null ? null : _snake(companions!),
    needs: needs.map(_snake).toList(),
    language: languageCode,
  );
}
