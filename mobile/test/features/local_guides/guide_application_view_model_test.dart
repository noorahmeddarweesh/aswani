import 'package:aswani/core/result/result.dart';
import 'package:aswani/features/local_guides/data/datasources/local_guides_mock_datasource.dart';
import 'package:aswani/features/local_guides/data/repositories/local_guides_repository_impl.dart';
import 'package:aswani/features/local_guides/domain/entities/guide_application.dart';
import 'package:aswani/features/local_guides/domain/entities/guide_enums.dart';
import 'package:aswani/features/local_guides/local_guides_providers.dart';
import 'package:aswani/features/local_guides/presentation/viewmodels/guide_application_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_photos.dart';

void main() {
  group('GuideApplicationViewModel Unit Tests', () {
    late ProviderContainer container;
    late LocalGuidesMockDataSource mockDataSource;
    late LocalGuidesRepositoryImpl repository;

    setUp(() {
      mockDataSource = LocalGuidesMockDataSource(delay: Duration.zero);
      repository = LocalGuidesRepositoryImpl(mockDataSource);
      container = ProviderContainer(
        overrides: [
          localGuidesDataSourceProvider.overrideWithValue(mockDataSource),
          localGuidesRepositoryProvider.overrideWithValue(repository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has empty fields and no errors', () {
      final state = container.read(guideApplicationViewModelProvider);
      expect(state.fullName, isEmpty);
      expect(state.languages, isEmpty);
      expect(state.specialties, isEmpty);
      expect(state.bio, isEmpty);
      expect(state.durations, isEmpty);
      expect(state.contact, isEmpty);
      expect(state.profilePhoto, isNull);
      expect(state.hasFieldErrors, isFalse);
      expect(state.isSubmitting, isFalse);
    });

    test('field setters and toggles update state correctly', () {
      final viewModel = container.read(
        guideApplicationViewModelProvider.notifier,
      );

      viewModel.setFullName('Fatima Hassan');
      expect(
        container.read(guideApplicationViewModelProvider).fullName,
        'Fatima Hassan',
      );

      viewModel.toggleLanguage(GuideLanguage.ar);
      viewModel.toggleLanguage(GuideLanguage.en);
      expect(container.read(guideApplicationViewModelProvider).languages, [
        GuideLanguage.ar,
        GuideLanguage.en,
      ]);

      viewModel.toggleLanguage(GuideLanguage.en);
      expect(container.read(guideApplicationViewModelProvider).languages, [
        GuideLanguage.ar,
      ]);

      viewModel.toggleSpecialty(GuideSpecialty.nubianCulture);
      viewModel.toggleSpecialty(GuideSpecialty.nile);
      expect(container.read(guideApplicationViewModelProvider).specialties, [
        GuideSpecialty.nubianCulture,
        GuideSpecialty.nile,
      ]);

      viewModel.setBio('Experienced guide with 10 years of Nile journeys.');
      expect(
        container.read(guideApplicationViewModelProvider).bio,
        'Experienced guide with 10 years of Nile journeys.',
      );

      viewModel.toggleDuration(GuideDuration.fewHours);
      viewModel.toggleDuration(GuideDuration.oneDay);
      expect(container.read(guideApplicationViewModelProvider).durations, [
        GuideDuration.fewHours,
        GuideDuration.oneDay,
      ]);

      viewModel.setContact('01012345678');
      expect(
        container.read(guideApplicationViewModelProvider).contact,
        '01012345678',
      );
    });

    test('validates required fields and reports field errors', () {
      final viewModel = container.read(
        guideApplicationViewModelProvider.notifier,
      );

      expect(viewModel.validate(), isFalse);
      var state = container.read(guideApplicationViewModelProvider);
      expect(state.fullNameError, 'REQUIRED');
      expect(state.languagesError, 'REQUIRED');
      expect(state.specialtiesError, 'REQUIRED');
      expect(state.bioError, 'REQUIRED');
      expect(state.contactError, 'REQUIRED');

      viewModel.setFullName('A');
      expect(viewModel.validate(), isFalse);
      expect(
        container.read(guideApplicationViewModelProvider).fullNameError,
        'TOO_SHORT',
      );

      viewModel.setFullName('Ali Hassan');
      viewModel.setLanguages([GuideLanguage.ar]);
      viewModel.setSpecialties([GuideSpecialty.historicalSites]);
      viewModel.setBio('Too short');
      expect(viewModel.validate(), isFalse);
      expect(
        container.read(guideApplicationViewModelProvider).bioError,
        'TOO_SHORT',
      );

      viewModel.setBio('Valid bio text with sufficient characters.');
      viewModel.setContact('12345'); // Invalid phone
      expect(viewModel.validate(), isFalse);
      expect(
        container.read(guideApplicationViewModelProvider).contactError,
        'INVALID_PHONE',
      );

      viewModel.setContact('01012345678'); // Valid Egyptian phone
      expect(viewModel.validate(), isTrue);
      state = container.read(guideApplicationViewModelProvider);
      expect(state.hasFieldErrors, isFalse);
    });

    test('validates photo extension and size limit', () {
      final viewModel = container.read(
        guideApplicationViewModelProvider.notifier,
      );

      // Unsupported extension
      viewModel.setProfilePhoto(testPhoto('photo.gif'));
      expect(
        container.read(guideApplicationViewModelProvider).photoError,
        'UNSUPPORTED_FILE_TYPE',
      );

      // Oversized photo
      viewModel.setProfilePhoto(testPhoto('photo_too_large.jpg'));
      expect(
        container.read(guideApplicationViewModelProvider).photoError,
        'FILE_TOO_LARGE',
      );

      // Valid extensions
      viewModel.setProfilePhoto(testPhoto('photo.jpg'));
      expect(
        container.read(guideApplicationViewModelProvider).photoError,
        isNull,
      );

      viewModel.setProfilePhoto(testPhoto('photo.png'));
      expect(
        container.read(guideApplicationViewModelProvider).photoError,
        isNull,
      );

      viewModel.setProfilePhoto(testPhoto('photo.webp'));
      expect(
        container.read(guideApplicationViewModelProvider).photoError,
        isNull,
      );
    });

    test('submits valid form successfully and returns 201 pending', () async {
      container.listen(guideApplicationViewModelProvider, (_, _) {});

      final viewModel = container.read(
        guideApplicationViewModelProvider.notifier,
      );

      viewModel.setFullName('Kareem Nader');
      viewModel.setLanguages([GuideLanguage.ar, GuideLanguage.en]);
      viewModel.setSpecialties([GuideSpecialty.nile]);
      viewModel.setBio(
        'Passionate local guide showing true Aswan hospitality.',
      );
      viewModel.setDurations([GuideDuration.oneDay]);
      viewModel.setContact('01123456789');

      final result = await viewModel.submit();
      expect(result, isA<Success<GuideApplicationResult>>());

      if (result case Success(:final value)) {
        expect(value.id, startsWith('app-'));
        expect(value.status, RequestStatus.pending);
      }
    });

    test('handles 409 ALREADY_APPLIED and preserves form draft', () async {
      container.listen(guideApplicationViewModelProvider, (_, _) {});

      final viewModel = container.read(
        guideApplicationViewModelProvider.notifier,
      );

      viewModel.setFullName('Sameh Zaki');
      viewModel.setLanguages([GuideLanguage.ar]);
      viewModel.setSpecialties([GuideSpecialty.nubianCulture]);
      viewModel.setBio('Sharing Nubian cultural stories and music.');
      viewModel.setContact('01200000001');

      // First submission succeeds
      final firstResult = await viewModel.submit();
      expect(firstResult, isA<Success<GuideApplicationResult>>());

      // Second submission with same phone returns 409 ALREADY_APPLIED
      final secondResult = await viewModel.submit();
      expect(secondResult, isA<Error<GuideApplicationResult>>());

      final state = container.read(guideApplicationViewModelProvider);
      expect(state.serverError, 'ALREADY_APPLIED');
      expect(state.contactError, 'ALREADY_APPLIED');
      // Inputs preserved
      expect(state.fullName, 'Sameh Zaki');
      expect(state.contact, '01200000001');
    });

    test('reset clears all fields back to initial state', () {
      final viewModel = container.read(
        guideApplicationViewModelProvider.notifier,
      );

      viewModel.setFullName('Ahmad');
      viewModel.setContact('01012345678');
      viewModel.reset();

      final state = container.read(guideApplicationViewModelProvider);
      expect(state.fullName, isEmpty);
      expect(state.contact, isEmpty);
    });
  });
}
