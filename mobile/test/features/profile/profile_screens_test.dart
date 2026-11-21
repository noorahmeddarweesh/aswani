import 'dart:async';
import 'dart:typed_data';

import 'package:aswani/core/config/app_settings.dart';
import 'package:aswani/core/network/upload.dart';
import 'package:aswani/core/router/app_router.dart';
import 'package:aswani/core/session/session_controller.dart';
import 'package:aswani/features/personalization/data/datasources/preferences_mock_datasource.dart';
import 'package:aswani/features/personalization/personalization_providers.dart';
import 'package:aswani/features/profile/data/datasources/profile_mock_datasource.dart';
import 'package:aswani/features/profile/profile_providers.dart';
import 'package:aswani/shared/widgets/photo_picker_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

Future<(ProviderContainer, GoRouter)> _open(
  WidgetTester tester,
  String location, {
  List<Override> overrides = const [],
}) async {
  final container = await pumpApp(tester, overrides: overrides);
  container
      .read(sessionProvider.notifier)
      .signedIn(
        const Session(
          userId: 'u_1',
          displayName: 'Laila Hassan',
          hasPreferences: true,
        ),
      );
  await tester.pumpAndSettle();
  final router = container.read(appRouterProvider);
  unawaited(router.push(location));
  await tester.pumpAndSettle();
  return (container, router);
}

void main() {
  testWidgets('profile shows the design, links open the right pages', (
    tester,
  ) async {
    final (_, r) = await _open(tester, '/profile');
    expect(find.text('Laila Hassan'), findsOneWidget);
    expect(find.text('Newcomer • Aswan, Egypt'), findsOneWidget);
    expect(find.text('160 points earned'), findsOneWidget);
    expect(find.text('1 report under review'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Guide requests'), 200);
    await tester.tap(find.text('Guide requests'));
    await tester.pumpAndSettle();
    expect(r.state.matchedLocation, '/guide-requests');
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('My posts'));
    await tester.pumpAndSettle();
    expect(r.state.matchedLocation, '/community/mine');
  });

  testWidgets('new profile photo shows on the profile and in the session', (
    tester,
  ) async {
    final (container, _) = await _open(
      tester,
      '/profile',
      overrides: [
        pickPhotosProvider.overrideWithValue(
          (_) async => [
            UploadFile(name: 'me.png', bytes: Uint8List(8), path: '/me.png'),
          ],
        ),
      ],
    );
    await tester.tap(find.bySemanticsLabel('Change profile photo'));
    await tester.pumpAndSettle();
    expect(find.text('Profile photo updated.'), findsOneWidget);
    expect(container.read(sessionProvider)!.avatarUrl, '/me.png');
  });

  testWidgets('View all lists saved places and stories, with filters', (
    tester,
  ) async {
    await _open(tester, '/profile/saved');
    expect(find.text('Philae Temple'), findsOneWidget);
    expect(find.text('Homes that speak in color'), findsOneWidget);
    await tester.tap(find.text('Stories'));
    await tester.pumpAndSettle();
    expect(find.text('Philae Temple'), findsNothing);
    expect(find.text('Homes that speak in color'), findsOneWidget);
  });

  testWidgets('language switches at once and is saved; notifications too', (
    tester,
  ) async {
    final (container, _) = await _open(tester, '/profile/settings');
    final mock =
        container.read(profileDataSourceProvider) as ProfileMockDataSource;

    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    expect(container.read(localeProvider).languageCode, 'ar');
    expect(find.text('الإعدادات'), findsOneWidget);
    expect(mock.lastSettingsPatch, {'language': 'ar'});

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(mock.lastSettingsPatch, {'notifications_enabled': false});
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
  });

  testWidgets('log out asks first, then goes to Welcome', (tester) async {
    final (container, r) = await _open(tester, '/profile/settings');
    await tester.scrollUntilVisible(find.text('Log out'), 300);
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Log out?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(container.read(sessionProvider), isNotNull);

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
    await tester.pumpAndSettle();
    expect(container.read(sessionProvider), isNull);
    expect(r.state.matchedLocation, '/welcome');
  });

  testWidgets('delete account sends the request, then logs out', (
    tester,
  ) async {
    final (container, r) = await _open(tester, '/profile/settings');
    await tester.scrollUntilVisible(find.text('Delete account'), 300);
    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    expect(find.text('Delete account?'), findsOneWidget);
    await tester.tap(find.text('Request deletion'));
    await tester.pumpAndSettle();
    expect(container.read(sessionProvider), isNull);
    expect(r.state.matchedLocation, '/welcome');
  });

  testWidgets('Interests opens filled in and Save goes back to Settings', (
    tester,
  ) async {
    final (container, r) = await _open(tester, '/profile/settings');
    final prefs = container.read(
      preferencesDataSourceProvider,
    ) as PreferencesMockDataSource;
    await tester.tap(find.text('Interests & personalization'));
    await tester.pumpAndSettle();
    expect(r.state.matchedLocation, '/profile/settings/interests');
    // Saved answer of step 1 is already chosen, so Continue works.
    for (var i = 0; i < 7; i++) {
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.text('Your preferences were saved.'), findsOneWidget);
    expect(r.state.matchedLocation, '/profile/settings');
    expect(prefs.lastSaved!['persona'], 'newcomer');
    expect(prefs.lastSaved!['interests'], ['nubian', 'local', 'photography']);
    // Still signed in with preferences: no jump back to Home.
    expect(container.read(sessionProvider)!.hasPreferences, isTrue);
  });
}
