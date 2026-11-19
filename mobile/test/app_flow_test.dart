import 'package:aswani/core/config/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('app opens on the welcome screen', (tester) async {
    await pumpApp(tester);
    expect(find.text('Discover the soul of Aswan'), findsOneWidget);
    expect(find.text('Start exploring'), findsOneWidget);
  });

  testWidgets('language chip switches to Arabic, right to left', (
    tester,
  ) async {
    final container = await pumpApp(tester);
    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();

    expect(container.read(localeProvider).languageCode, 'ar');
    final title = find.text('اكتشف روح أسوان');
    expect(title, findsOneWidget);
    expect(Directionality.of(tester.element(title)), TextDirection.rtl);
  });

  testWidgets('onboarding: Next moves through the pages to sign up', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Start exploring'));
    await tester.pumpAndSettle();
    expect(find.text('Discover the Beauty of Aswan'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Get Started'), findsOneWidget);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('Create your account'), findsOneWidget);
  });

  testWidgets('sign in shows field errors when the form is empty', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.textContaining('Have an account?'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('This field is required'), findsNWidgets(2));
  });

  testWidgets('wrong password shows the API error, right one opens Home', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.textContaining('Have an account?'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('signIn.identifier')),
      'laila@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('signIn.password')),
      'nope1234',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Email, phone or password is incorrect'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('signIn.password')),
      'Aswan2026',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Laila'), findsWidgets);
    expect(find.text('Curated for you'), findsOneWidget);
  });

  testWidgets('new account goes through the 8 personalisation steps', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Start exploring'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('signUp.name')), 'Omar Ali');
    await tester.enterText(
      find.byKey(const Key('signUp.identifier')),
      'omar@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('signUp.password')),
      'Aswan2026',
    );
    await tester.enterText(
      find.byKey(const Key('signUp.confirm')),
      'Aswan2026',
    );
    await tester.tap(find.byKey(const Key('signUp.terms')));
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.text('STEP 1 OF 8'), findsOneWidget);
    // Continue is disabled until an answer is chosen.
    final continueButton = find.widgetWithText(FilledButton, 'Continue');
    expect(tester.widget<FilledButton>(continueButton).onPressed, isNull);

    await tester.tap(find.text("I'm visiting Aswan"));
    await tester.pumpAndSettle();
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.text('STEP 2 OF 8'), findsOneWidget);

    // Skip steps 2 to 7.
    for (var i = 0; i < 6; i++) {
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
    }
    expect(find.text('STEP 8 OF 8'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Start exploring'));
    await tester.pumpAndSettle();
    expect(find.text('Curated for you'), findsOneWidget);
  });
}
