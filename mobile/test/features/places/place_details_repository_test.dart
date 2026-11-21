import 'package:aswani/core/result/result.dart';
import 'package:aswani/features/places/data/datasources/place_details_mock_datasource.dart';
import 'package:aswani/features/places/data/repositories/place_details_repository_impl.dart';
import 'package:aswani/features/places/domain/entities/place_details.dart';
import 'package:aswani/features/places/domain/entities/place_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PlaceDetailsRepositoryImpl repository;

  setUp(() {
    repository = PlaceDetailsRepositoryImpl(
      PlaceDetailsMockDataSource(delay: Duration.zero),
    );
  });

  group('PlaceDetailsRepositoryImpl', () {
    test('getPlaceDetails returns wrapped PlaceDetails entity', () async {
      final result = await repository.getPlaceDetails('philae');
      expect(result, isA<Success>());
      final details = (result as Success).value as PlaceDetails;
      expect(details.id, 'philae');
      expect(details.name('en'), 'Philae Temple');
      expect(details.location('en'), 'Agilkia Island, Aswan');
      expect(details.facts.length, 2);
      expect(details.images.isNotEmpty, isTrue);
    });

    test('getPlaceDetails returns Error for unknown place', () async {
      final result = await repository.getPlaceDetails('unknown-place');
      expect(result, isA<Error>());
      final failure = (result as Error).failure;
      expect(failure.code, 'PLACE_NOT_FOUND');
    });

    test('createPlaceReport and getPlaceReportsMine round trip', () async {
      final report = PlaceReportCreate(
        placeId: 'philae',
        reason: PlaceReportReason.incorrectLocation,
        details: 'Location coordinates seem slightly shifted.',
      );

      final result = await repository.createPlaceReport(report);
      expect(result, isA<Success>());
      final resultValue = (result as Success).value as PlaceReportResult;
      expect(resultValue.status, 'pending');
      expect(resultValue.pointsPending, 25);

      final mineResult = await repository.getPlaceReportsMine();
      expect(mineResult, isA<Success>());
      final paged = (mineResult as Success).value;
      expect(paged.data.any((r) => r.id == resultValue.id), isTrue);
      final item = paged.data.firstWhere((r) => r.id == resultValue.id);
      expect(item.place.id, 'philae');
      expect(item.reason, PlaceReportReason.incorrectLocation);
      expect(item.status, 'pending');
    });
  });
}
