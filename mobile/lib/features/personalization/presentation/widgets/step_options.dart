import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../domain/entities/preferences.dart';

/// Icon, title and subtitle of one answer.
typedef OptionView = ({IconData icon, String title, String? subtitle});

/// Labels and icons for every answer, in one place (matches the designs).
extension PersonalizationOptions on AppLocalizations {
  OptionView persona(Persona v) => switch (v) {
    Persona.visitor => (
      icon: LucideIcons.compass,
      title: personaVisitorTitle,
      subtitle: personaVisitorSubtitle,
    ),
    Persona.newcomer => (
      icon: LucideIcons.mapPin,
      title: personaNewcomerTitle,
      subtitle: personaNewcomerSubtitle,
    ),
    Persona.resident => (
      icon: LucideIcons.house,
      title: personaResidentTitle,
      subtitle: personaResidentSubtitle,
    ),
  };

  OptionView purpose(Purpose v) => switch (v) {
    Purpose.tourism => (
      icon: LucideIcons.compass,
      title: purposeTourismTitle,
      subtitle: purposeTourismSubtitle,
    ),
    Purpose.living => (
      icon: LucideIcons.house,
      title: purposeLivingTitle,
      subtitle: purposeLivingSubtitle,
    ),
    Purpose.studying => (
      icon: LucideIcons.landmark,
      title: purposeStudyingTitle,
      subtitle: purposeStudyingSubtitle,
    ),
    Purpose.work => (
      icon: LucideIcons.settings,
      title: purposeWorkTitle,
      subtitle: purposeWorkSubtitle,
    ),
    Purpose.family => (
      icon: LucideIcons.heart,
      title: purposeFamilyTitle,
      subtitle: purposeFamilySubtitle,
    ),
    Purpose.other => (
      icon: LucideIcons.ellipsis,
      title: purposeOtherTitle,
      subtitle: purposeOtherSubtitle,
    ),
  };

  OptionView stay(StayLength v) => switch (v) {
    StayLength.fewDays => (
      icon: LucideIcons.clock,
      title: stayFewDaysTitle,
      subtitle: stayFewDaysSubtitle,
    ),
    StayLength.week => (
      icon: LucideIcons.calendar,
      title: stayWeekTitle,
      subtitle: stayWeekSubtitle,
    ),
    StayLength.month => (
      icon: LucideIcons.map,
      title: stayMonthTitle,
      subtitle: stayMonthSubtitle,
    ),
    StayLength.severalMonths => (
      icon: LucideIcons.sparkles,
      title: stayMonthsTitle,
      subtitle: stayMonthsSubtitle,
    ),
    StayLength.longTerm => (
      icon: LucideIcons.house,
      title: stayLongTermTitle,
      subtitle: stayLongTermSubtitle,
    ),
    StayLength.notSure => (
      icon: LucideIcons.ellipsis,
      title: stayNotSureTitle,
      subtitle: stayNotSureSubtitle,
    ),
  };

  OptionView interest(Interest v) => switch (v) {
    Interest.historical => (
      icon: LucideIcons.landmark,
      title: interestHistorical,
      subtitle: null,
    ),
    Interest.nubian => (
      icon: LucideIcons.palette,
      title: interestNubian,
      subtitle: null,
    ),
    Interest.nature => (
      icon: LucideIcons.map,
      title: interestNature,
      subtitle: null,
    ),
    Interest.local => (
      icon: LucideIcons.sparkles,
      title: interestLocal,
      subtitle: null,
    ),
    Interest.food => (
      icon: LucideIcons.compass,
      title: interestFood,
      subtitle: null,
    ),
    Interest.community => (
      icon: LucideIcons.users,
      title: interestCommunity,
      subtitle: null,
    ),
    Interest.traditionalFood => (
      icon: LucideIcons.heart,
      title: interestTraditionalFood,
      subtitle: null,
    ),
    Interest.photography => (
      icon: LucideIcons.imagePlus,
      title: interestPhotography,
      subtitle: null,
    ),
  };

  OptionView style(TravelStyle v) => switch (v) {
    TravelStyle.calm => (
      icon: LucideIcons.heart,
      title: styleCalmTitle,
      subtitle: styleCalmSubtitle,
    ),
    TravelStyle.adventurous => (
      icon: LucideIcons.compass,
      title: styleAdventurousTitle,
      subtitle: styleAdventurousSubtitle,
    ),
    TravelStyle.cultural => (
      icon: LucideIcons.palette,
      title: styleCulturalTitle,
      subtitle: styleCulturalSubtitle,
    ),
    TravelStyle.social => (
      icon: LucideIcons.users,
      title: styleSocialTitle,
      subtitle: styleSocialSubtitle,
    ),
    TravelStyle.hidden => (
      icon: LucideIcons.mapPin,
      title: styleHiddenTitle,
      subtitle: styleHiddenSubtitle,
    ),
    TravelStyle.mix => (
      icon: LucideIcons.sparkles,
      title: styleMixTitle,
      subtitle: styleMixSubtitle,
    ),
  };

  OptionView companions(Companions v) => switch (v) {
    Companions.solo => (
      icon: LucideIcons.user,
      title: withSoloTitle,
      subtitle: withSoloSubtitle,
    ),
    Companions.friends => (
      icon: LucideIcons.users,
      title: withFriendsTitle,
      subtitle: withFriendsSubtitle,
    ),
    Companions.family => (
      icon: LucideIcons.house,
      title: withFamilyTitle,
      subtitle: withFamilySubtitle,
    ),
    Companions.partner => (
      icon: LucideIcons.heart,
      title: withPartnerTitle,
      subtitle: withPartnerSubtitle,
    ),
    Companions.group => (
      icon: LucideIcons.map,
      title: withGroupTitle,
      subtitle: withGroupSubtitle,
    ),
    Companions.mayChange => (
      icon: LucideIcons.ellipsis,
      title: withMayChangeTitle,
      subtitle: withMayChangeSubtitle,
    ),
  };

  OptionView need(Need v) => switch (v) {
    Need.findingPlaces => (
      icon: LucideIcons.search,
      title: needFindingPlacesTitle,
      subtitle: needFindingPlacesSubtitle,
    ),
    Need.gettingAround => (
      icon: LucideIcons.mapPin,
      title: needGettingAroundTitle,
      subtitle: needGettingAroundSubtitle,
    ),
    Need.localRecommendations => (
      icon: LucideIcons.sparkles,
      title: needLocalRecsTitle,
      subtitle: needLocalRecsSubtitle,
    ),
    Need.localGuides => (
      icon: LucideIcons.user,
      title: needLocalGuidesTitle,
      subtitle: needLocalGuidesSubtitle,
    ),
    Need.activities => (
      icon: LucideIcons.calendar,
      title: needActivitiesTitle,
      subtitle: needActivitiesSubtitle,
    ),
    Need.localServices => (
      icon: LucideIcons.settings,
      title: needServicesTitle,
      subtitle: needServicesSubtitle,
    ),
  };
}
