import 'package:aswani/core/errors/app_exception.dart';
import 'package:aswani/core/errors/failure.dart';
import 'package:aswani/features/places/data/datasources/place_details_mock_datasource.dart';
import 'package:aswani/features/places/data/models/place_report_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PlaceDetailsMockDataSource dataSource;

  setUp(() {
    dataSource = PlaceDetailsMockDataSource(delay: Duration.zero);
  });

  group('PlaceDetailsMockDataSource - getPlaceDetails', () {
    test('returns extended place details for philae', () async {
      final details = await dataSource.getPlaceDetails('philae');
      expect(details.place.id, 'philae');
      expect(details.place.nameEn, 'Philae Temple');
      expect(details.locationEn, 'Agilkia Island, Aswan');
      expect(details.locationAr, 'جزيرة أجيليكيا، أسوان');
      expect(details.images.isNotEmpty, isTrue);
      expect(details.facts.length, 2);
      expect(details.facts.any((f) => f.type == 'access'), isTrue);
      expect(details.facts.any((f) => f.type == 'hours'), isTrue);
    });

    test('throws 404 PLACE_NOT_FOUND for unknown place', () async {
      expect(
        () => dataSource.getPlaceDetails('unknown-place-id'),
        throwsA(
          isA<AppException>()
              .having((e) => e.code, 'code', ErrorCodes.placeNotFound)
              .having((e) => e.statusCode, 'status', 404),
        ),
      );
    });
  });

  group('PlaceDetailsMockDataSource - createPlaceReport', () {
    test('submits valid place report returning 25 points_pending', () async {
      const report = PlaceReportCreateDto(
        placeId: 'philae',
        reason: 'incorrect_information',
        details: 'Visiting hours are now from 8 AM to 5 PM.',
        photo: 'supporting_photo.jpg',
      );

      final result = await dataSource.createPlaceReport(report);
      expect(result.status, 'pending');
      expect(result.pointsPending, 25);
      expect(result.id, startsWith('rep-'));

      // Verify it appears in /mine
      final mine = await dataSource.getPlaceReportsMine();
      expect(mine.data.any((r) => r.id == result.id), isTrue);
      final item = mine.data.firstWhere((r) => r.id == result.id);
      expect(item.place.id, 'philae');
      expect(item.reason, 'incorrect_information');
    });

    test('throws 404 PLACE_NOT_FOUND for unknown place report', () async {
      const report = PlaceReportCreateDto(
        placeId: 'non-existent-place',
        reason: 'not_exist',
        details: 'Does not exist',
      );

      expect(
        () => dataSource.createPlaceReport(report),
        throwsA(
          isA<AppException>()
              .having((e) => e.code, 'code', ErrorCodes.placeNotFound)
              .having((e) => e.statusCode, 'status', 404),
        ),
      );
    });

    test('rejects empty or too long details (1..1000 chars)', () async {
      const emptyReport = PlaceReportCreateDto(
        placeId: 'philae',
        reason: 'other',
        details: '   ',
      );

      expect(
        () => dataSource.createPlaceReport(emptyReport),
        throwsA(
          isA<AppException>()
              .having((e) => e.code, 'code', ErrorCodes.validation)
              .having((e) => e.statusCode, 'status', 422)
              .having(
                (e) => e.details['details'],
                'details',
                'VALIDATION_ERROR',
              ),
        ),
      );

      final tooLongReport = PlaceReportCreateDto(
        placeId: 'philae',
        reason: 'other',
        details: 'a' * 1001,
      );

      expect(
        () => dataSource.createPlaceReport(tooLongReport),
        throwsA(
          isA<AppException>()
              .having((e) => e.code, 'code', ErrorCodes.validation)
              .having((e) => e.statusCode, 'status', 422),
        ),
      );
    });

    test('rejects photo exceeding 5 MB with FILE_TOO_LARGE', () async {
      const report = PlaceReportCreateDto(
        placeId: 'philae',
        reason: 'incorrect_information',
        details: 'Valid details note',
        photo: 'my_camera_file_too_large.jpg',
      );

      expect(
        () => dataSource.createPlaceReport(report),
        throwsA(
          isA<AppException>().having(
            (e) => e.details['photo'],
            'photo',
            'FILE_TOO_LARGE',
          ),
        ),
      );
    });

    test(
      'rejects unsupported photo extension with UNSUPPORTED_FILE_TYPE',
      () async {
        const report = PlaceReportCreateDto(
          placeId: 'philae',
          reason: 'incorrect_information',
          details: 'Valid details note',
          photo: 'proof.gif',
        );

        expect(
          () => dataSource.createPlaceReport(report),
          throwsA(
            isA<AppException>().having(
              (e) => e.details['photo'],
              'photo',
              'UNSUPPORTED_FILE_TYPE',
            ),
          ),
        );
      },
    );
  });
}
