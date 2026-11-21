import 'package:aswani/core/errors/app_exception.dart';
import 'package:aswani/features/local_guides/data/datasources/local_guides_remote_datasource.dart';
import 'package:aswani/features/local_guides/data/models/guide_application_dto.dart';
import 'package:aswani/features/local_guides/data/models/guide_request_dto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_api.dart';

const _mockGuideJson = {
  'id': 'youssef-el-nuby',
  'full_name': 'Youssef El Nuby',
  'photo': 'https://api.aswani.app/images/guides/youssef.jpg',
  'city': 'Aswan',
  'tagline': 'Nubian stories • History walks • Arabic & English',
  'languages': ['ar', 'en'],
  'specialties': ['nubian_culture', 'historical_sites', 'local_experiences'],
  'bio': 'Passionate about local stories, Nubian architecture, and Nile experiences.',
  'durations': ['few_hours', 'one_day', 'multiple_days'],
  'is_featured': true,
  'is_verified': false,
};

void main() {
  late FakeApi api;
  late LocalGuidesRemoteDataSource remote;

  setUp(() {
    api = FakeApi(
      (_) => reply(200, {
        'data': [_mockGuideJson],
        'meta': {'page': 1, 'limit': 20, 'total': 1, 'total_pages': 1},
      }),
    );
    remote = LocalGuidesRemoteDataSource(api.client());
  });

  group('LocalGuidesRemoteDataSource - GET /api/guides', () {
    test('sends query parameters and parses list + meta', () async {
      final result = await remote.getGuides(
        specialty: 'nubian_culture',
        q: 'Youssef',
        page: 2,
        limit: 10,
      );

      final req = api.requests.single;
      expect(req.method, 'GET');
      expect(req.path, '/guides');
      expect(req.queryParameters, {
        'page': 2,
        'limit': 10,
        'specialty': 'nubian_culture',
        'q': 'Youssef',
      });

      expect(result.data.length, 1);
      final guide = result.data.first;
      expect(guide.id, 'youssef-el-nuby');
      expect(guide.fullName, 'Youssef El Nuby');
      expect(guide.photo, 'https://api.aswani.app/images/guides/youssef.jpg');
      expect(guide.isFeatured, isTrue);
      expect(guide.isVerified, isFalse);
      expect(result.meta.page, 1);
      expect(result.meta.total, 1);
    });

    test('omits optional query parameters when not provided', () async {
      await remote.getGuides();
      final req = api.requests.single;
      expect(req.queryParameters.containsKey('specialty'), isFalse);
      expect(req.queryParameters.containsKey('q'), isFalse);
      expect(req.queryParameters['page'], 1);
      expect(req.queryParameters['limit'], 20);
    });
  });

  group('LocalGuidesRemoteDataSource - GET /api/guides/{id}', () {
    test('calls /guides/{id} and parses single item wrapper', () async {
      api.handler = (_) => reply(200, {'data': _mockGuideJson});

      final guide = await remote.getGuide('youssef-el-nuby');

      final req = api.requests.single;
      expect(req.method, 'GET');
      expect(req.path, '/guides/youssef-el-nuby');
      expect(guide.id, 'youssef-el-nuby');
      expect(guide.fullName, 'Youssef El Nuby');
    });

    test('properly surfaces 404 GUIDE_NOT_FOUND exception', () async {
      api.handler = (_) => reply(404, apiError('GUIDE_NOT_FOUND'));

      expect(
        () => remote.getGuide('unknown-guide'),
        throwsA(
          isA<AppException>()
              .having((e) => e.code, 'code', 'GUIDE_NOT_FOUND')
              .having((e) => e.statusCode, 'statusCode', 404),
        ),
      );
    });
  });

  group('LocalGuidesRemoteDataSource - POST /api/guide-requests', () {
    test('sends JSON body and parses 201 pending response', () async {
      api.handler = (_) => reply(201, {
        'data': {'id': 'req-123', 'status': 'pending'},
      });

      const requestDto = GuideRequestCreateDto(
        guideId: 'youssef-el-nuby',
        date: '2026-11-25',
        duration: 'custom',
        durationHours: 6,
        startTime: '10:00',
        groupSize: 4,
        language: 'en',
        interests: ['nubian_culture', 'nile'],
        notes: 'Looking forward to the tour.',
      );

      final result = await remote.createGuideRequest(requestDto);

      final req = api.requests.single;
      expect(req.method, 'POST');
      expect(req.path, '/guide-requests');
      expect(req.data, requestDto.toJson());
      expect(result.id, 'req-123');
      expect(result.status, 'pending');
    });

    test('surfaces 422 DATE_IN_PAST validation error', () async {
      api.handler = (_) =>
          reply(422, apiError('VALIDATION_ERROR', {'date': 'DATE_IN_PAST'}));

      const requestDto = GuideRequestCreateDto(
        guideId: 'youssef-el-nuby',
        date: '2020-01-01',
        duration: 'one_day',
        startTime: '10:00',
        groupSize: 2,
        language: 'ar',
      );

      expect(
        () => remote.createGuideRequest(requestDto),
        throwsA(
          isA<AppException>()
              .having((e) => e.code, 'code', 'VALIDATION_ERROR')
              .having((e) => e.details['date'], 'date details', 'DATE_IN_PAST'),
        ),
      );
    });
  });

  group('LocalGuidesRemoteDataSource - GET /api/guide-requests/mine', () {
    test('sends query params and parses requests list with meta', () async {
      api.handler = (_) => reply(200, {
        'data': [
          {
            'id': 'req-123',
            'guide': {
              'id': 'youssef-el-nuby',
              'full_name': 'Youssef El Nuby',
              'photo': 'https://api.aswani.app/images/guides/youssef.jpg',
            },
            'date': '2026-11-25',
            'duration': 'one_day',
            'duration_hours': null,
            'start_time': '09:00',
            'group_size': 2,
            'language': 'en',
            'interests': ['nubian_culture'],
            'status': 'pending',
            'created_at': '2026-11-21T00:00:00Z',
          },
        ],
        'meta': {'page': 1, 'limit': 20, 'total': 1, 'total_pages': 1},
      });

      final result = await remote.getGuideRequestsMine(page: 1, limit: 20);

      final req = api.requests.single;
      expect(req.method, 'GET');
      expect(req.path, '/guide-requests/mine');
      expect(req.queryParameters, {'page': 1, 'limit': 20});

      expect(result.data.length, 1);
      final item = result.data.first;
      expect(item.id, 'req-123');
      expect(item.guide.fullName, 'Youssef El Nuby');
      expect(
        item.guide.photo,
        'https://api.aswani.app/images/guides/youssef.jpg',
      );
      expect(item.status, 'pending');
    });
  });

  group('LocalGuidesRemoteDataSource - POST /api/guide-applications', () {
    test(
      'sends multipart/form-data with repeated lists and parses 201 response',
      () async {
        api.handler = (_) => reply(201, {
          'data': {'id': 'app-999', 'status': 'pending'},
        });

        const applicationDto = GuideApplicationCreateDto(
          fullName: 'Mahmoud Hassan',
          languages: ['ar', 'en'],
          specialties: ['nubian_culture', 'nile'],
          bio: 'Local guide with 10 years experience.',
          durations: ['few_hours', 'one_day'],
          contact: '01012345678',
          profilePhoto: 'dummy_photo.jpg',
        );

        final result = await remote.createGuideApplication(applicationDto);

        final req = api.requests.single;
        expect(req.method, 'POST');
        expect(req.path, '/guide-applications');
        expect(req.data, isA<FormData>());

        final formData = req.data as FormData;
        final fieldKeys = formData.fields.map((e) => e.key).toList();
        expect(fieldKeys, contains('full_name'));
        expect(fieldKeys, contains('bio'));
        expect(fieldKeys, contains('contact'));
        expect(formData.fields.where((e) => e.key == 'languages').length, 2);
        expect(formData.fields.where((e) => e.key == 'specialties').length, 2);
        expect(formData.fields.where((e) => e.key == 'durations').length, 2);

        final fileKeys = formData.files.map((e) => e.key).toList();
        expect(fileKeys, contains('profile_photo'));

        expect(result.id, 'app-999');
        expect(result.status, 'pending');
      },
    );

    test(
      'surfaces 409 ALREADY_APPLIED when contact number is duplicated',
      () async {
        api.handler = (_) => reply(409, apiError('ALREADY_APPLIED'));

        const applicationDto = GuideApplicationCreateDto(
          fullName: 'Duplicate Applicant',
          languages: ['ar'],
          specialties: ['nile'],
          bio: 'Explorer',
          durations: ['few_hours'],
          contact: '01012345678',
        );

        expect(
          () => remote.createGuideApplication(applicationDto),
          throwsA(
            isA<AppException>()
                .having((e) => e.code, 'code', 'ALREADY_APPLIED')
                .having((e) => e.statusCode, 'statusCode', 409),
          ),
        );
      },
    );
  });
}
