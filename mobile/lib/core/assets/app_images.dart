/// Every image the app uses. Files live in `assets/images/<feature>/`.
///
/// A missing file shows a branded placeholder (see `AppImage`), so screens
/// work before the designer exports the final photos. To add a photo, save it
/// with the exact name below; no code change is needed.
abstract final class AppImages {
  static const String _onboarding = 'assets/images/onboarding';
  static const String _home = 'assets/images/home';
  static const String _places = 'assets/images/places';

  // Onboarding
  static const String welcomeHero = '$_onboarding/welcome_hero.jpg';
  static const String welcomeHero2 = '$_onboarding/welcome_hero_2.jpg';
  static const String welcomeHero3 = '$_onboarding/welcome_hero_3.jpg';
  static const String onboardingNile = '$_onboarding/onboarding_nile.jpg';
  static const String onboardingNubian = '$_onboarding/onboarding_nubian.jpg';
  static const String onboardingPhilae = '$_onboarding/onboarding_philae.jpg';
  static const String onboardingTemple = '$_onboarding/onboarding_temple.jpg';
  static const String onboardingMarket = '$_onboarding/onboarding_market.jpg';

  // Home
  static const String homeHero = '$_home/home_hero_nile.jpg';
  static const String homeHero2 = '$_home/home_hero_2.jpg';
  static const String homeHero3 = '$_home/home_hero_3.jpg';
  static const String homeStory = '$_home/story_nubian_heritage.jpg';
  static const String homeGuide = '$_home/guide_youssef.jpg';

  /// Demo profile photo of the mock user (Laila).
  static const String avatarLaila = '$_home/avatar_laila.jpg';

  // Places
  static const String philaeTemple = '$_places/philae_temple.jpg';
  static const String elephantineIsland = '$_places/elephantine_island.jpg';
  static const String nubianVillage = '$_places/nubian_village.jpg';
  static const String nubianMuseum = '$_places/nubian_museum.jpg';
}
