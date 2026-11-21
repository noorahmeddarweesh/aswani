import 'package:aswani/core/errors/app_exception.dart';
import 'package:aswani/features/places/data/datasources/place_details_remote_datasource.dart';
import 'package:aswani/features/places/data/models/place_report_dto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_api.dart';

const _mockPlaceDetailsJson = {
  'id': 'philae',
  'category': 'history',
  'name_en': 'Philae Temple',
  'name_ar': 'معبد فيلة',
  'label_en': 'Heritage & history',
  'label_ar': 'تراث وتاريخ',
  'tagline_en': 'History on an island',
  'tagline_ar': 'تاريخ على جزيرة',
  'city_en': 'Aswan',
  'city_ar': 'أسوان',
  'image': 'https://api.test/images/places/philae.jpg',
  'is_curated': true,
  'is_editors_pick': true,
  'is_bookmarked': false,
  'location_en': 'Agilkia Island, Aswan',
  'location_ar': 'جزيرة أجيليكيا، أسوان',
  'about_en': 'An archaeological complex on an island in the Nile.',
  'about_ar': 'مجمع أثري على جزيرة في النيل.',
  'images': ['https://api.test/images/places/philae.jpg'],
  'facts': [
    {'type': 'access', 'label_en': 'Boat access', 'label_ar': 'الوصول بالقارب'},
    {
      'type': 'hours',
      'label_en': 'Check before visiting',
      'label_ar': 'تحقق قبل الزيارة',
    },
  ],
};

const _mockPlaceReportItemJson = {
  'id': 'rep-1',
  'place': {
    'id': 'philae',
    'name_en': 'Philae Temple',
    'name_ar': 'معبد فيلة',
    'image': 'https://api.test/images/places/philae.jpg',
  },
  'reason': 'incorrect_information',
  'status': 'pending',
  'points_awarded': null,
  'created_at': '2026-11-21T00:00:00Z',
};

void main() {
  late FakeApi api;
  late PlaceDetailsRemoteDataSource remote;

  setUp(() {
    api = FakeApi(
      (_) => reply(200, {
        'data': [_mockPlaceReportItemJson],
        'meta': {'page': 1, 'limit': 20, 'total': 1, 'total_pages': 1},
      }),
    );
    remote = PlaceDetailsRemoteDataSource(api.client());
  });

  group('PlaceDetailsRemoteDataSource - POST /api/place-reports', () {
    test('sends multipart FormData and parses 201 pending response with points_pending', () async {
      api.handler = (_) => reply(201, {
        'data': {'id': 'rep-101', 'status': 'pending', 'points_pending': 25},
      });

      const reportDto = PlaceReportCreateDto(
        placeId: 'philae',
        reason: 'incorrect_information',
        details: 'The opening hours listed are outdated. It opens at 09:00.',
        photo: 'supporting_photo.jpg',
      );

      final result = await remote.createPlaceReport(reportDto);

      final req = api.requests.single;
      expect(req.method, 'POST');
      expect(req.path, '/place-reports');
      expect(req.data, isA<FormData>());

      final formData = req.data as FormData;
      final fields = Map.fromEntries(
        formData.fields.map((e) => MapEntry(e.key, e.value)),
      );
      expect(fields['place_id'], 'philae');
      expect(fields['reason'], 'incorrect_information');
      expect(fields['details'], contains('opening hours'));

      final files = formData.files.map((e) => e.key).toList();
      expect(files, contains('photo'));

      expect(result.id, 'rep-101');
      expect(result.status, 'pending');
      expect(result.pointsPending, 25);
    });

    test('handles report submission without photo', () async {
      api.handler = (_) => reply(201, {
        'data': {'id': 'rep-102', 'status': 'pending', 'points_pending': 25},
      });

      const reportDto = PlaceReportCreateDto(
        placeId: 'elephantine',
        reason: 'temporarily_closed',
        details: 'Ferry terminal under maintenance.',
      );

      final result = await remote.createPlaceReport(reportDto);

      final req = api.requests.single;
      expect(req.method, 'POST');
      expect(req.path, '/place-reports');
      final formData = req.data as FormData;
      expect(formData.files, isEmpty);
      expect(result.id, 'rep-102');
    });

    test(
      'surfaces 404 PLACE_NOT_FOUND error when place does not exist',
      () async {
        api.handler = (_) => reply(404, apiError('PLACE_NOT_FOUND'));

        const reportDto = PlaceReportCreateDto(
          placeId: 'unknown-place',
          reason: 'not_exist',
          details: 'Cannot find this place anywhere.',
        );

        expect(
          () => remote.createPlaceReport(reportDto),
          throwsA(
            isA<AppException>()
                .having((e) => e.code, 'code', 'PLACE_NOT_FOUND')
                .having((e) => e.statusCode, 'statusCode', 404),
          ),
        );
      },
    );

    test('surfaces 422 VALIDATION_ERROR for invalid report inputs', () async {
      api.handler = (_) => reply(
        422,
        apiError('VALIDATION_ERROR', {'details': 'VALIDATION_ERROR'}),
      );

      const reportDto = PlaceReportCreateDto(
        placeId: 'philae',
        reason: 'other',
        details: '',
      );

      expect(
        () => remote.createPlaceReport(reportDto),
        throwsA(
          isA<AppException>()
              .having((e) => e.code, 'code', 'VALIDATION_ERROR')
              .having(
                (e) => e.details['details'],
                'details error',
                'VALIDATION_ERROR',
              ),
        ),
      );
    });
  });

  group('PlaceDetailsRemoteDataSource - GET /api/place-reports/mine', () {
    test('sends query parameters and parses reports list with meta', () async {
      api.handler = (_) => reply(200, {
        'data': [_mockPlaceReportItemJson],
        'meta': {'page': 1, 'limit': 20, 'total': 1, 'total_pages': 1},
      });

      final result = await remote.getPlaceReportsMine(page: 1, limit: 20);

      final req = api.requests.single;
      expect(req.method, 'GET');
      expect(req.path, '/place-reports/mine');
      expect(req.queryParameters, {'page': 1, 'limit': 20});

      expect(result.data.length, 1);
      final item = result.data.first;
      expect(item.id, 'rep-1');
      expect(item.place.id, 'philae');
      expect(item.place.nameEn, 'Philae Temple');
      expect(item.place.nameAr, 'معبد فيلة');
      expect(item.reason, 'incorrect_information');
      expect(item.status, 'pending');
      expect(item.pointsAwarded, isNull);
      expect(result.meta.total, 1);
    });
  });

  group('PlaceDetailsRemoteDataSource - GET /api/places/{id}', () {
    test('fetches place details and parses contract v0.2 fields', () async {
      api.handler = (_) => reply(200, {'data': _mockPlaceDetailsJson});

      final details = await remote.getPlaceDetails('philae');

      final req = api.requests.single;
      expect(req.method, 'GET');
      expect(req.path, '/places/philae');
      expect(details.place.id, 'philae');
      expect(details.place.nameEn, 'Philae Temple');
      expect(details.locationEn, 'Agilkia Island, Aswan');
      expect(details.aboutEn, contains('archaeological complex'));
      expect(details.images.length, 1);
      expect(details.facts.length, 2);
      expect(details.facts.first.type, 'access');
    });

    test('properly surfaces 404 PLACE_NOT_FOUND error', () async {
      api.handler = (_) => reply(404, apiError('PLACE_NOT_FOUND'));

      expect(
        () => remote.getPlaceDetails('unknown-place'),
        throwsA(
          isA<AppException>()
              .having((e) => e.code, 'code', 'PLACE_NOT_FOUND')
              .having((e) => e.statusCode, 'statusCode', 404),
        ),
      );
    });
  });
}
