import 'dart:ui';

import 'package:aswani/app.dart';
import 'package:aswani/core/config/retry_policy.dart';
import 'package:aswani/features/community/community_providers.dart';
import 'package:aswani/features/community/data/datasources/community_mock_datasource.dart';
import 'package:aswani/features/contributions/contributions_providers.dart';
import 'package:aswani/features/contributions/data/datasources/contributions_datasource.dart';
import 'package:aswani/features/contributions/data/datasources/contributions_mock_datasource.dart';
import 'package:aswani/features/culture/culture_providers.dart';
import 'package:aswani/features/local_guides/data/datasources/local_guides_mock_datasource.dart';
import 'package:aswani/features/local_guides/local_guides_providers.dart';
import 'package:aswani/features/places/data/datasources/place_details_datasource.dart';
import 'package:aswani/features/places/data/datasources/place_details_mock_datasource.dart';
import 'package:aswani/features/places/place_details_providers.dart';
import 'package:aswani/features/profile/data/datasources/profile_mock_datasource.dart';
import 'package:aswani/features/profile/profile_providers.dart';
import 'package:aswani/features/culture/data/datasources/culture_mock_datasource.dart';
import 'package:aswani/core/network/connectivity.dart';
import 'package:aswani/features/auth/auth_providers.dart';
import 'package:aswani/features/auth/data/datasources/auth_mock_datasource.dart';
import 'package:aswani/features/personalization/data/datasources/preferences_mock_datasource.dart';
import 'package:aswani/features/personalization/personalization_providers.dart';
import 'package:aswani/features/places/data/datasources/places_mock_datasource.dart';
import 'package:aswani/features/places/places_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

/// Mock data sources without network delay, so tests run fast.
/// [network] drives the online/offline state; default: always online.
/// [placeDetails] and [contributions] swap in another source (e.g. one
/// that fails), since a provider can only be overridden once.
List<Override> fastMocks({
  Stream<bool>? network,
  PlaceDetailsDataSource? placeDetails,
  ContributionsDataSource? contributions,
}) => [
  isOnlineProvider.overrideWith((ref) => network ?? Stream.value(true)),
  authDataSourceProvider.overrideWithValue(
    AuthMockDataSource(delay: Duration.zero),
  ),
  preferencesDataSourceProvider.overrideWithValue(
    PreferencesMockDataSource(delay: Duration.zero),
  ),
  placesDataSourceProvider.overrideWithValue(
    PlacesMockDataSource(delay: Duration.zero),
  ),
  communityDataSourceProvider.overrideWithValue(
    CommunityMockDataSource(delay: Duration.zero),
  ),
  cultureDataSourceProvider.overrideWithValue(
    CultureMockDataSource(delay: Duration.zero),
  ),
  contributionsDataSourceProvider.overrideWithValue(
    contributions ?? ContributionsMockDataSource(delay: Duration.zero),
  ),
  profileDataSourceProvider.overrideWithValue(
    ProfileMockDataSource(delay: Duration.zero),
  ),
  placeDetailsDataSourceProvider.overrideWithValue(
    placeDetails ?? PlaceDetailsMockDataSource(delay: Duration.zero),
  ),
  localGuidesDataSourceProvider.overrideWithValue(
    LocalGuidesMockDataSource(delay: Duration.zero),
  ),
];

/// Pumps the whole app on a phone-sized screen and returns its container.
Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  List<Override> overrides = const [],
  List<Override>? mocks,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  reduceMotion(tester);
  final container = ProviderContainer(
    retry: noAutoRetry,
    overrides: [...mocks ?? fastMocks(), ...overrides],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const AswaniApp()),
  );
  await tester.pumpAndSettle();
  return container;
}

/// Looping animations (carousel, shimmer) never settle, so widget tests run
/// with the system "reduce motion" setting on, exactly as a user could.
void reduceMotion(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}
