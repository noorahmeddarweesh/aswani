import 'package:aswani/core/l10n/generated/app_localizations.dart';
import 'package:aswani/core/theme/app_theme.dart';
import 'package:aswani/features/local_guides/presentation/screens/guide_application_received_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Widget buildSubject({
    Locale locale = const Locale('en'),
    VoidCallback? onBackToGuidesPressed,
  }) {
    return MaterialApp(
      theme: AppTheme.light,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: GuideApplicationReceivedScreen(
        onBackToGuidesPressed: onBackToGuidesPressed,
      ),
    );
  }

  group('GuideApplicationReceivedScreen Widget Tests', () {
    testWidgets('renders all screen elements matching guide_application-1.jpg',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Person icon inside gold squircle tile
      expect(find.byIcon(LucideIcons.user), findsOneWidget);

      // Headline
      expect(find.text('Application received'), findsOneWidget);

      // Body copy
      expect(
        find.text(
          "We'll review the information and contact you. Submission does not indicate official verification or certification.",
        ),
        findsOneWidget,
      );

      // Back to guides CTA
      expect(find.text('Back to guides'), findsOneWidget);
    });

    testWidgets('tapping Back to guides invokes callback', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      var tapped = false;
      await tester.pumpWidget(
        buildSubject(onBackToGuidesPressed: () => tapped = true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Back to guides'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('renders Arabic strings and RTL directionality in Arabic locale',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildSubject(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      expect(find.text('تم استلام الطلب'), findsOneWidget);
      expect(
        find.text(
          'سنراجع المعلومات ونتواصل معك. لا يعني التقديم اعتمادًا أو توثيقًا رسميًا.',
        ),
        findsOneWidget,
      );
      expect(find.text('العودة للمرشدين'), findsOneWidget);

      final textDirection = Directionality.of(tester.element(find.byType(Scaffold)));
      expect(textDirection, TextDirection.rtl);
    });
  });
}
