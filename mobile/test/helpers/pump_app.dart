import 'dart:ui';

import 'package:aswani/app.dart';
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
List<Override> fastMocks({Stream<bool>? network}) => [
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
];

/// Pumps the whole app on a phone-sized screen and returns its container.
Future<ProviderContainer> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  reduceMotion(tester);
  final container = ProviderContainer(overrides: fastMocks());
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
