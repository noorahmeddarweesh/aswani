import 'package:aswani/core/network/upload.dart';
import 'package:aswani/core/l10n/generated/app_localizations.dart';
import 'package:aswani/core/theme/app_theme.dart';
import 'package:aswani/features/local_guides/data/datasources/local_guides_mock_datasource.dart';
import 'package:aswani/features/local_guides/data/models/guide_application_dto.dart';
import 'package:aswani/features/local_guides/data/repositories/local_guides_repository_impl.dart';
import 'package:aswani/features/local_guides/domain/entities/guide_application.dart';
import 'package:aswani/features/local_guides/domain/entities/guide_enums.dart';
import 'package:aswani/features/local_guides/local_guides_providers.dart';
import 'package:aswani/features/local_guides/presentation/screens/guide_application_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  late LocalGuidesMockDataSource mockDataSource;
  late LocalGuidesRepositoryImpl repository;

  setUp(() {
    mockDataSource = LocalGuidesMockDataSource(delay: Duration.zero);
    repository = LocalGuidesRepositoryImpl(mockDataSource);
  });

  Widget buildSubject({
    Locale locale = const Locale('en'),
    ValueChanged<GuideApplicationResult>? onSubmittedSuccess,
    Future<UploadFile?> Function()? onPickPhoto,
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
      home: GuideApplicationScreen(
        onSubmittedSuccess: onSubmittedSuccess,
        onPickPhoto: onPickPhoto,
      ),
    );

    if (container != null) {
      return UncontrolledProviderScope(container: container, child: app);
    }

    return ProviderScope(
      overrides: [
        localGuidesDataSourceProvider.overrideWithValue(mockDataSource),
        localGuidesRepositoryProvider.overrideWithValue(repository),
      ],
      child: app,
    );
  }

  group('GuideApplicationScreen Widget Tests', () {
    testWidgets('renders all screen elements matching guide_application.jpg', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Top app bar
      expect(find.text('Become a guide'), findsOneWidget);
      expect(find.byType(IconButton), findsAtLeastNWidgets(1));

      // Intro text
      expect(
        find.text(
          'Show visitors Aswan through your local perspective. Details are reviewed before publication.',
        ),
        findsOneWidget,
      );

      // Profile photo picker tile
      expect(find.text('Profile photo'), findsOneWidget);

      // Form fields
      expect(find.text('Full name *'), findsOneWidget);
      expect(find.text('Name shown to visitors'), findsOneWidget);

      expect(find.text('Languages *'), findsOneWidget);
      expect(find.text('Arabic, English'), findsOneWidget);

      expect(find.text('Tour specialties *'), findsOneWidget);
      expect(find.text('Nubian culture, Nile...'), findsOneWidget);

      expect(find.text('Short biography *'), findsOneWidget);
      expect(
        find.text('Share your experience and interests...'),
        findsOneWidget,
      );

      expect(find.text('Available durations'), findsOneWidget);
      expect(find.text('Few hours, full day'), findsOneWidget);

      expect(find.text('Contact details *'), findsOneWidget);
      expect(find.text('+20'), findsOneWidget);

      // Submit button
      expect(find.text('Submit application'), findsOneWidget);
    });

    testWidgets('multi-select bottom sheets open and update selections', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Open languages bottom sheet
      await tester.tap(find.text('Arabic, English'));
      await tester.pumpAndSettle();

      expect(find.text('Select languages'), findsOneWidget);
      expect(find.text('Arabic'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);

      // Tap Arabic and English
      await tester.tap(find.text('Arabic'));
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // Tap Done
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Field now displays selected values
      expect(find.text('Arabic, English'), findsOneWidget);

      // Open specialties bottom sheet
      await tester.tap(find.text('Nubian culture, Nile...'));
      await tester.pumpAndSettle();

      expect(find.text('Select tour specialties'), findsOneWidget);
      await tester.tap(find.text('Nubian culture'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('Nubian culture'), findsOneWidget);
    });

    testWidgets('validation errors show when submitting empty form', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Tap submit with empty fields
      await tester.tap(find.text('Submit application'));
      await tester.pumpAndSettle();

      // Required errors appear
      expect(find.text('This field is required'), findsAtLeastNWidgets(2));
    });

    testWidgets('invalid Egyptian phone number displays error', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Enter invalid phone
      final phoneField = find.widgetWithText(TextFormField, '+20');
      await tester.enterText(phoneField, '123456');
      await tester.pumpAndSettle();

      // Tap submit
      await tester.tap(find.text('Submit application'));
      await tester.pumpAndSettle();

      expect(
        find.text('Enter a valid Egyptian mobile number (e.g. 010xxxxxxxx)'),
        findsOneWidget,
      );
    });

    testWidgets('submitting valid application succeeds and invokes callback', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      GuideApplicationResult? result;

      await tester.pumpWidget(
        buildSubject(onSubmittedSuccess: (res) => result = res),
      );
      await tester.pumpAndSettle();

      // Fill full name
      final nameField = find.widgetWithText(
        TextFormField,
        'Name shown to visitors',
      );
      await tester.enterText(nameField, 'Mahmoud Bilal');

      // Select languages
      await tester.tap(find.text('Arabic, English'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Arabic'));
      await tester.tap(find.text('English'));
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Select specialties
      await tester.tap(find.text('Nubian culture, Nile...'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nubian culture'));
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Fill biography
      final bioField = find.widgetWithText(
        TextFormField,
        'Share your experience and interests...',
      );
      await tester.enterText(
        bioField,
        'Local guide passionate about Nubian heritage and Nile explorations.',
      );

      // Select durations
      await tester.tap(find.text('Few hours, full day'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Full day'));
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Fill contact details
      final phoneField = find.widgetWithText(TextFormField, '+20');
      await tester.enterText(phoneField, '01099887766');

      // Tap submit
      await tester.tap(find.text('Submit application'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.status, RequestStatus.pending);
    });

    testWidgets('handles 409 ALREADY_APPLIED and shows error banner', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Pre-seed an application with this contact
      await mockDataSource.createGuideApplication(
        const GuideApplicationCreateDto(
          fullName: 'Existing Guide',
          languages: ['ar'],
          specialties: ['nile'],
          bio: 'Existing biography with sufficient text length.',
          durations: ['one_day'],
          contact: '01011112222',
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Fill same contact
      final nameField = find.widgetWithText(
        TextFormField,
        'Name shown to visitors',
      );
      await tester.enterText(nameField, 'Second Attempt');

      await tester.tap(find.text('Arabic, English'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Arabic'));
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nubian culture, Nile...'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nile'));
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      final bioField = find.widgetWithText(
        TextFormField,
        'Share your experience and interests...',
      );
      await tester.enterText(
        bioField,
        'Another guide application with valid length.',
      );

      final phoneField = find.widgetWithText(TextFormField, '+20');
      await tester.enterText(phoneField, '01011112222');

      // Submit
      await tester.tap(find.text('Submit application'));
      await tester.pumpAndSettle();

      expect(
        find.text('An application with this mobile number already exists.'),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets(
      'renders Arabic strings and RTL directionality in Arabic locale',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(buildSubject(locale: const Locale('ar')));
        await tester.pumpAndSettle();

        expect(find.text('كن مرشدًا'), findsOneWidget);
        expect(find.text('الاسم الكامل *'), findsOneWidget);
        expect(find.text('اللغات *'), findsOneWidget);
        expect(find.text('تخصصات الجولات *'), findsOneWidget);
        expect(find.text('نبذة شخصية قصيرة *'), findsOneWidget);
        expect(find.text('المدد المتاحة'), findsOneWidget);
        expect(find.text('بيانات التواصل *'), findsOneWidget);
        expect(find.text('إرسال الطلب'), findsOneWidget);

        final textDirection = Directionality.of(
          tester.element(find.byType(Scaffold)),
        );
        expect(textDirection, TextDirection.rtl);
      },
    );
  });
}
