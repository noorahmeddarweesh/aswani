enum Persona { visitor, newcomer, resident }

enum Purpose { tourism, living, studying, work, family, other }

enum StayLength { fewDays, week, month, severalMonths, longTerm, notSure }

enum Interest {
  historical,
  nubian,
  nature,
  local,
  food,
  community,
  traditionalFood,
  photography,
}

enum TravelStyle { calm, adventurous, cultural, social, hidden, mix }

enum Companions { solo, friends, family, partner, group, mayChange }

enum Need {
  findingPlaces,
  gettingAround,
  localRecommendations,
  localGuides,
  activities,
  localServices,
}

/// Everything the user chose in the 8 personalisation steps. Any answer may
/// be empty: every step can be skipped.
class Preferences {
  const Preferences({
    this.persona,
    this.purpose,
    this.stayLength,
    this.interests = const {},
    this.styles = const {},
    this.companions,
    this.needs = const {},
    this.languageCode = 'en',
  });

  final Persona? persona;
  final Purpose? purpose;
  final StayLength? stayLength;
  final Set<Interest> interests;
  final Set<TravelStyle> styles;
  final Companions? companions;
  final Set<Need> needs;
  final String languageCode;

  Preferences copyWith({
    Persona? persona,
    Purpose? purpose,
    StayLength? stayLength,
    Set<Interest>? interests,
    Set<TravelStyle>? styles,
    Companions? companions,
    Set<Need>? needs,
    String? languageCode,
  }) => Preferences(
    persona: persona ?? this.persona,
    purpose: purpose ?? this.purpose,
    stayLength: stayLength ?? this.stayLength,
    interests: interests ?? this.interests,
    styles: styles ?? this.styles,
    companions: companions ?? this.companions,
    needs: needs ?? this.needs,
    languageCode: languageCode ?? this.languageCode,
  );
}
