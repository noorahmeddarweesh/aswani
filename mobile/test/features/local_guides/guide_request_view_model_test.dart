import 'package:aswani/features/local_guides/domain/entities/guide_enums.dart';
import 'package:aswani/features/local_guides/presentation/viewmodels/guide_request_form_state.dart';
import 'package:aswani/features/local_guides/presentation/viewmodels/guide_request_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Cairo Time & Date Validation', () {
    test('accurately calculates Cairo DST vs standard time offsets', () {
      // Winter: Dec 15, 2026 (Cairo Standard Time is UTC+2)
      final winterUtc = DateTime.utc(2026, 12, 15, 12, 0);
      final winterCairo = getCairoDateTime(winterUtc);
      expect(winterCairo.difference(winterUtc).inHours, equals(2));

      // Summer: July 15, 2026 (Cairo Summer Time is UTC+3)
      final summerUtc = DateTime.utc(2026, 7, 15, 12, 0);
      final summerCairo = getCairoDateTime(summerUtc);
      expect(summerCairo.difference(summerUtc).inHours, equals(3));
    });

    test('getCairoTodayDateString formats as YYYY-MM-DD', () {
      final utc = DateTime.utc(2026, 5, 1, 10, 0);
      expect(getCairoTodayDateString(utc), equals('2026-05-01'));
    });

    test('isCairoDateTodayOrFuture validates correctly', () {
      final fixedUtc = DateTime.utc(2026, 6, 10, 12, 0); // Today is 2026-06-10
      expect(isCairoDateTodayOrFuture('2026-06-10', fixedUtc), isTrue);
      expect(isCairoDateTodayOrFuture('2026-06-11', fixedUtc), isTrue);
      expect(isCairoDateTodayOrFuture('2026-06-09', fixedUtc), isFalse);
      expect(isCairoDateTodayOrFuture('2025-12-31', fixedUtc), isFalse);
    });
  });

  group('GuideRequestViewModel', () {
    late ProviderContainer container;
    const testGuideId = 'youssef-el-nuby';

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    GuideRequestViewModel getNotifier() =>
        container.read(guideRequestViewModelProvider(testGuideId).notifier);
    GuideRequestFormState getState() =>
        container.read(guideRequestViewModelProvider(testGuideId));

    test('initial state defaults per design_spec and contract_A', () {
      final state = getState();
      expect(state.guideId, equals(testGuideId));
      expect(state.date, isNull);
      expect(state.duration, equals(RequestDuration.oneDay));
      expect(state.durationHours, equals(6));
      expect(state.startTime, equals('09:00'));
      expect(state.groupSize, equals(2));
      expect(state.language, equals(GuideLanguage.en));
      expect(state.interests, isEmpty);
      expect(state.notes, isNull);
      expect(state.dateError, isNull);
      expect(state.customHoursError, isNull);
      expect(state.isValid, isFalse); // Date is still null
    });

    test('setDate accepts valid today or future date and clears errors', () {
      final cairoToday = getCairoTodayDateString();
      getNotifier().setDate(cairoToday);

      expect(getState().date, equals(cairoToday));
      expect(getState().dateError, isNull);
      expect(getState().isValid, isTrue);
    });

    test('setDate sets DATE_IN_PAST error when past date provided', () {
      getNotifier().setDate('2020-01-01');

      expect(getState().date, equals('2020-01-01'));
      expect(getState().dateError, equals('DATE_IN_PAST'));
      expect(getState().isValid, isFalse);
    });

    test('setDate sets REQUIRED error when empty or null provided', () {
      getNotifier().setDate('   ');
      expect(getState().date, isNull);
      expect(getState().dateError, equals('REQUIRED'));
    });

    test('duration changes enforce duration_hours mapping rules', () {
      // 1. Switch to fewHours -> duration_hours must be null
      getNotifier().setDuration(RequestDuration.fewHours);
      expect(getState().duration, equals(RequestDuration.fewHours));
      expect(getState().durationHours, isNull);

      // 2. Switch to twoDays -> duration_hours must be null
      getNotifier().setDuration(RequestDuration.twoDays);
      expect(getState().duration, equals(RequestDuration.twoDays));
      expect(getState().durationHours, isNull);

      // 3. Switch to threeDays -> duration_hours must be null
      getNotifier().setDuration(RequestDuration.threeDays);
      expect(getState().duration, equals(RequestDuration.threeDays));
      expect(getState().durationHours, isNull);

      // 4. Switch to oneDay -> duration_hours must be 6
      getNotifier().setDuration(RequestDuration.oneDay);
      expect(getState().duration, equals(RequestDuration.oneDay));
      expect(getState().durationHours, equals(6));

      // 5. Switch to custom -> duration_hours preserves 6 (or defaults to 4 if null) and requires 1..12
      getNotifier().setDuration(RequestDuration.custom);
      expect(getState().duration, equals(RequestDuration.custom));
      expect(getState().durationHours, equals(6));
    });

    test('setCustomHours validates 1..12 range', () {
      getNotifier().setDuration(RequestDuration.custom);

      getNotifier().setCustomHours(8);
      expect(getState().durationHours, equals(8));
      expect(getState().customHoursError, isNull);

      getNotifier().setCustomHours(0);
      expect(getState().customHoursError, equals('INVALID_HOURS'));

      getNotifier().setCustomHours(13);
      expect(getState().customHoursError, equals('INVALID_HOURS'));

      getNotifier().setCustomHours(12);
      expect(getState().durationHours, equals(12));
      expect(getState().customHoursError, isNull);
    });

    test('setGroupSize clamps count between 1 and 20', () {
      getNotifier().setGroupSize(5);
      expect(getState().groupSize, equals(5));

      getNotifier().setGroupSize(0);
      expect(getState().groupSize, equals(1));

      getNotifier().setGroupSize(25);
      expect(getState().groupSize, equals(20));
    });

    test('setStartTime and setLanguage update state correctly', () {
      getNotifier().setStartTime('14:30');
      expect(getState().startTime, equals('14:30'));

      getNotifier().setLanguage(GuideLanguage.ar);
      expect(getState().language, equals(GuideLanguage.ar));
    });

    test('validate enforces all constraints', () {
      // Initially invalid due to missing date
      expect(getNotifier().validate(), isFalse);
      expect(getState().dateError, equals('REQUIRED'));

      // In past date -> invalid
      getNotifier().setDate('2021-05-10');
      expect(getNotifier().validate(), isFalse);
      expect(getState().dateError, equals('DATE_IN_PAST'));

      // Valid date -> valid
      getNotifier().setDate(getCairoTodayDateString());
      expect(getNotifier().validate(), isTrue);

      // Custom duration with invalid hours -> invalid
      getNotifier().setDuration(RequestDuration.custom);
      getNotifier().setCustomHours(15);
      expect(getNotifier().validate(), isFalse);
      expect(getState().customHoursError, equals('INVALID_HOURS'));

      // Fix custom hours -> valid
      getNotifier().setCustomHours(5);
      expect(getNotifier().validate(), isTrue);
    });

    test('toCreatePayload constructs complete GuideRequestCreate entity', () {
      final cairoToday = getCairoTodayDateString();
      getNotifier().setDate(cairoToday);
      getNotifier().setStartTime('10:00');
      getNotifier().setGroupSize(4);
      getNotifier().setLanguage(GuideLanguage.fr);
      getNotifier().setNotes(' Looking forward to Nubian history. ');

      // With oneDay duration -> duration_hours is 6
      final payloadOneDay = getState().toCreatePayload();
      expect(payloadOneDay.guideId, equals(testGuideId));
      expect(payloadOneDay.date, equals(cairoToday));
      expect(payloadOneDay.duration, equals(RequestDuration.oneDay));
      expect(payloadOneDay.durationHours, equals(6));
      expect(payloadOneDay.startTime, equals('10:00'));
      expect(payloadOneDay.groupSize, equals(4));
      expect(payloadOneDay.language, equals(GuideLanguage.fr));
      expect(payloadOneDay.notes, equals('Looking forward to Nubian history.'));

      // With twoDays duration -> duration_hours is omitted (null)
      getNotifier().setDuration(RequestDuration.twoDays);
      final payloadTwoDays = getState().toCreatePayload();
      expect(payloadTwoDays.duration, equals(RequestDuration.twoDays));
      expect(payloadTwoDays.durationHours, isNull);

      // With custom duration -> duration_hours preserved
      getNotifier().setDuration(RequestDuration.custom);
      getNotifier().setCustomHours(7);
      final payloadCustom = getState().toCreatePayload();
      expect(payloadCustom.duration, equals(RequestDuration.custom));
      expect(payloadCustom.durationHours, equals(7));
    });
  });
}
