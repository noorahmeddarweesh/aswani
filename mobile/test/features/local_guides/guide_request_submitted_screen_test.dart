import 'package:aswani/core/l10n/generated/app_localizations.dart';
import 'package:aswani/core/theme/app_theme.dart';
import 'package:aswani/features/local_guides/presentation/screens/guide_request_submitted_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  const testGuideId = 'youssef-el-nuby';

  Widget buildSubject({
    VoidCallback? onHomePressed,
    Locale locale = const Locale('en'),
  }) {
    return MaterialApp(
      theme: AppTheme.light,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: GuideRequestSubmittedScreen(
        guideId: testGuideId,
        onHomePressed: onHomePressed,
      ),
    );
  }

  group('GuideRequestSubmittedScreen Widget Tests', () {
    testWidgets(
      'renders all screen sections and elements matching guide_request_done.jpg',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        // Squircle check tile
        expect(find.byKey(const Key('submitted_check_tile')), findsOneWidget);
        expect(find.byIcon(LucideIcons.check), findsOneWidget);

        // Title
        expect(find.byKey(const Key('submitted_title')), findsOneWidget);
        expect(find.text('Request submitted'), findsOneWidget);

        // Body text
        expect(find.byKey(const Key('submitted_body')), findsOneWidget);
        expect(
          find.text(
            "Your request is under review. It is not a confirmed booking yet; we'll notify you when the guide responds.",
          ),
          findsOneWidget,
        );

        // 3 status dots
        expect(find.byKey(const Key('submitted_status_dots')), findsOneWidget);

        // Pinned Back to home CTA
        expect(
          find.byKey(const Key('submitted_back_to_home_button')),
          findsOneWidget,
        );
        expect(find.text('Back to home'), findsOneWidget);
      },
    );

    testWidgets('tapping Back to home triggers onHomePressed callback', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      var homePressed = false;
      await tester.pumpWidget(
        buildSubject(onHomePressed: () => homePressed = true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('submitted_back_to_home_button')));
      await tester.pumpAndSettle();

      expect(homePressed, isTrue);
    });

    testWidgets('renders Arabic strings and RTL layout in Arabic locale', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildSubject(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      expect(find.text('تم إرسال الطلب'), findsOneWidget);
      expect(
        find.text(
          "طلبك قيد المراجعة. ليس حجزًا مؤكدًا بعد؛ سنخطرك عندما يرد المرشد.",
        ),
        findsOneWidget,
      );
      expect(find.text('العودة للرئيسية'), findsOneWidget);

      final directionality = Directionality.of(
        tester.element(find.text('تم إرسال الطلب')),
      );
      expect(directionality, equals(TextDirection.rtl));
    });
  });
}
