import 'package:aswani/features/personalization/data/mappers/preferences_mapper.dart';
import 'package:aswani/features/personalization/domain/entities/preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps answers to the snake_case API body', () {
    const prefs = Preferences(
      persona: Persona.visitor,
      stayLength: StayLength.fewDays,
      interests: {Interest.traditionalFood, Interest.nubian},
      needs: {Need.localRecommendations},
      languageCode: 'ar',
    );

    final json = prefs.toDto().toJson();

    expect(json['persona'], 'visitor');
    expect(json['purpose'], isNull);
    expect(json['stay_length'], 'few_days');
    expect(json['interests'], containsAll(['traditional_food', 'nubian']));
    expect(json['needs'], ['local_recommendations']);
    expect(json['language'], 'ar');
  });
}
