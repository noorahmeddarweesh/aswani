import 'package:aswani/core/l10n/generated/app_localizations.dart';
import 'package:aswani/core/theme/app_theme.dart';
import 'package:aswani/features/local_guides/domain/entities/guide_enums.dart';
import 'package:aswani/features/local_guides/domain/entities/guide_request.dart';
import 'package:aswani/features/local_guides/presentation/screens/guide_request_screen.dart';
import 'package:aswani/features/local_guides/presentation/viewmodels/guide_request_form_state.dart';
import 'package:aswani/features/local_guides/presentation/viewmodels/guide_request_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  const testGuideId = 'youssef-el-nuby';

  Widget buildSubject({
    String guideId = testGuideId,
    ValueChanged<GuideRequestCreate>? onReviewPressed,
    VoidCallback? onBackPressed,
    Locale locale = const Locale('en'),
    ProviderContainer? container,
  }) {
    final app = MaterialApp(
      theme: AppTheme.light,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: GuideRequestScreen(
        guideId: guideId,
        onReviewPressed: onReviewPressed,
        onBackPressed: onBackPressed,
      ),
    );

    if (container != null) {
      return UncontrolledProviderScope(container: container, child: app);
    }

    return ProviderScope(child: app);
  }

  group('GuideRequestScreen Widget Tests', () {
    testWidgets(
      'renders all screen sections and elements matching requesting_a_guide.jpg',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        // Top bar title
        expect(find.text('Request a guide'), findsOneWidget);

        // Intro description
        expect(
          find.text(
            'Tell us what fits your plans. Choose exactly how long you need.',
          ),
          findsOneWidget,
        );

        // Field 1: Preferred date
        expect(find.text('Preferred date'), findsOneWidget);
        expect(find.text('Select date'), findsOneWidget);
        expect(find.byIcon(LucideIcons.calendar), findsOneWidget);

        // Field 2: Tour duration
        expect(find.text('Tour duration'), findsOneWidget);
        expect(find.text('A few hours'), findsOneWidget);
        expect(find.text('One day'), findsOneWidget);
        expect(find.text('Two days'), findsOneWidget);
        expect(find.text('3 days'), findsOneWidget);
        expect(find.text('Custom'), findsOneWidget);
        // "One day" is selected by default and has check icon
        expect(find.byIcon(LucideIcons.check), findsOneWidget);

        // Side-by-side Start time & Group size
        expect(find.text('Start time'), findsOneWidget);
        expect(find.text('09:00'), findsOneWidget);
        expect(find.byIcon(LucideIcons.clock), findsOneWidget);

        expect(find.text('Group size'), findsOneWidget);
        expect(find.text('2 people'), findsOneWidget);
        expect(find.byIcon(LucideIcons.users), findsOneWidget);

        // Field 3: Preferred language
        expect(find.text('Preferred language'), findsOneWidget);
        expect(find.text('English'), findsOneWidget);
        expect(find.byIcon(LucideIcons.chevronDown), findsOneWidget);

        // Field 4: Additional notes
        expect(find.text('Additional notes (optional)'), findsOneWidget);
        expect(find.byKey(const Key('request_notes_field')), findsOneWidget);

        // Fixed bottom CTA
        expect(find.byKey(const Key('request_review_button')), findsOneWidget);
        expect(find.text('Review request'), findsOneWidget);
      },
    );

    testWidgets(
      'duration selection changes highlight and reveals custom hours stepper',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        // Tap "A few hours"
        await tester.tap(find.byKey(const Key('duration_few_hours')));
        await tester.pumpAndSettle();

        // Custom stepper should not be shown
        expect(find.byKey(const Key('custom_hours_value')), findsNothing);

        // Tap "Custom"
        await tester.tap(find.byKey(const Key('duration_custom')));
        await tester.pumpAndSettle();

        // Custom stepper should now be visible with default 4 hours
        expect(find.byKey(const Key('custom_hours_value')), findsOneWidget);
        expect(find.text('4 hours'), findsOneWidget);

        // Tap "+" to increment hours
        await tester.tap(find.byKey(const Key('custom_hours_increment')));
        await tester.pumpAndSettle();
        expect(find.text('5 hours'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping Review request without date displays required error and halts submission',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        var reviewPressed = false;
        await tester.pumpWidget(
          buildSubject(onReviewPressed: (_) => reviewPressed = true),
        );
        await tester.pumpAndSettle();

        // Tap review button
        await tester.tap(find.byKey(const Key('request_review_button')));
        await tester.pumpAndSettle();

        // Validation fails and error text appears
        expect(
          find.byKey(const Key('request_date_error_text')),
          findsOneWidget,
        );
        expect(find.text('Date is required'), findsOneWidget);
        expect(reviewPressed, isFalse);
      },
    );

    testWidgets('DATE_IN_PAST displays translated field-level error', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Set past date in viewModel
      container
          .read(guideRequestViewModelProvider(testGuideId).notifier)
          .setDate('2020-01-01');

      await tester.pumpWidget(buildSubject(container: container));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('request_date_error_text')), findsOneWidget);
      expect(find.text('Date cannot be in the past'), findsOneWidget);
    });

    testWidgets(
      'valid form invokes onReviewPressed with complete GuideRequestCreate draft',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final container = ProviderContainer();
        addTearDown(container.dispose);

        final cairoToday = getCairoTodayDateString();
        final vm = container.read(
          guideRequestViewModelProvider(testGuideId).notifier,
        );
        vm.setDate(cairoToday);
        vm.setStartTime('10:30');
        vm.setGroupSize(3);

        GuideRequestCreate? capturedPayload;
        await tester.pumpWidget(
          buildSubject(
            container: container,
            onReviewPressed: (payload) => capturedPayload = payload,
          ),
        );
        await tester.pumpAndSettle();

        // Enter notes
        await tester.enterText(
          find.byKey(const Key('request_notes_field')),
          'Interested in Nubian music and culture.',
        );
        await tester.pumpAndSettle();

        // Tap review button
        await tester.tap(find.byKey(const Key('request_review_button')));
        await tester.pumpAndSettle();

        expect(capturedPayload, isNotNull);
        expect(capturedPayload!.guideId, equals(testGuideId));
        expect(capturedPayload!.date, equals(cairoToday));
        expect(capturedPayload!.duration, equals(RequestDuration.oneDay));
        expect(capturedPayload!.durationHours, equals(6));
        expect(capturedPayload!.startTime, equals('10:30'));
        expect(capturedPayload!.groupSize, equals(3));
        expect(capturedPayload!.language, equals(GuideLanguage.en));
        expect(
          capturedPayload!.notes,
          equals('Interested in Nubian music and culture.'),
        );
      },
    );

    testWidgets(
      'renders Arabic strings and RTL directionality in Arabic locale',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(buildSubject(locale: const Locale('ar')));
        await tester.pumpAndSettle();

        expect(find.text('طلب مرشد'), findsOneWidget);
        expect(find.text('التاريخ المفضل'), findsOneWidget);
        expect(find.text('مدة الجولة'), findsOneWidget);
        expect(find.text('يوم واحد'), findsOneWidget);
        expect(find.text('بضع ساعات'), findsOneWidget);
        expect(find.text('وقت البدء'), findsOneWidget);
        expect(find.text('حجم المجموعة'), findsOneWidget);
        expect(find.text('شخصان'), findsOneWidget);
        expect(find.text('اللغة المفضلة'), findsOneWidget);
        expect(find.text('ملاحظات إضافية (اختياري)'), findsOneWidget);
        expect(find.text('مراجعة الطلب'), findsOneWidget);

        final directionality = Directionality.of(
          tester.element(find.text('طلب مرشد')),
        );
        expect(directionality, equals(TextDirection.rtl));
      },
    );
  });
}
