import '../../domain/entities/preferences.dart';
import '../models/preferences_dto.dart';

/// camelCase enum name -> snake_case API value, e.g. fewDays -> few_days.
String _snake(Enum value) => value.name.replaceAllMapped(
  RegExp('[A-Z]'),
  (m) => '_${m.group(0)!.toLowerCase()}',
);

/// snake_case API value -> enum; unknown values are dropped.
T? _enum<T extends Enum>(List<T> values, String? wire) =>
    values.where((v) => _snake(v) == wire).firstOrNull;

Set<T> _enums<T extends Enum>(List<T> values, List<String> wires) => {
  for (final w in wires) ?_enum(values, w),
};

extension PreferencesDtoMapper on PreferencesDto {
  Preferences toEntity() => Preferences(
    persona: _enum(Persona.values, persona),
    purpose: _enum(Purpose.values, purpose),
    stayLength: _enum(StayLength.values, stayLength),
    interests: _enums(Interest.values, interests),
    styles: _enums(TravelStyle.values, travelStyles),
    companions: _enum(Companions.values, companions),
    needs: _enums(Need.values, needs),
    languageCode: language,
  );
}

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
