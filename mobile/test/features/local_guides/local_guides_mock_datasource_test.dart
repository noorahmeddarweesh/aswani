import 'package:aswani/core/errors/app_exception.dart';
import 'package:aswani/core/errors/failure.dart';
import 'package:aswani/features/local_guides/data/datasources/local_guides_mock_datasource.dart';
import 'package:aswani/features/local_guides/data/models/guide_application_dto.dart';
import 'package:aswani/features/local_guides/data/models/guide_request_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalGuidesMockDataSource dataSource;

  setUp(() {
    dataSource = LocalGuidesMockDataSource(delay: Duration.zero);
  });

  group('LocalGuidesMockDataSource - getGuides', () {
    test('returns default 3 sample guides with meta', () async {
      final paged = await dataSource.getGuides();
      expect(paged.data.length, 3);
      expect(paged.meta.page, 1);
      expect(paged.meta.total, 3);
      expect(paged.meta.totalPages, 1);

      final youssef = paged.data.firstWhere((g) => g.id == 'youssef-el-nuby');
      expect(youssef.isFeatured, isTrue);
      expect(youssef.isVerified, isFalse);
      expect(youssef.city, 'Aswan');
      expect(youssef.languages, contains('ar'));
      expect(youssef.specialties, contains('nubian_culture'));
    });

    test('filters by specialty', () async {
      final nileGuides = await dataSource.getGuides(specialty: 'nile');
      expect(nileGuides.data.length, 1);
      expect(nileGuides.data.first.fullName, 'Ahmed Salem');

      final nubianGuides = await dataSource.getGuides(
        specialty: 'nubian_culture',
      );
      expect(nubianGuides.data.length, 2);
    });

    test('searches by q (name or specialty)', () async {
      final byName = await dataSource.getGuides(q: 'Mariam');
      expect(byName.data.length, 1);
      expect(byName.data.first.fullName, 'Mariam Ahmed');

      final bySpec = await dataSource.getGuides(q: 'photography');
      expect(bySpec.data.length, 1);
      expect(bySpec.data.first.fullName, 'Ahmed Salem');
    });

    test('enforces pagination bounds (1 <= limit <= 50, page >= 1)', () async {
      expect(
        () => dataSource.getGuides(limit: 51),
        throwsA(
          isA<AppException>()
              .having((e) => e.code, 'code', ErrorCodes.validation)
              .having((e) => e.statusCode, 'status', 422),
        ),
      );

      expect(
        () => dataSource.getGuides(page: 0),
        throwsA(
          isA<AppException>()
              .having((e) => e.code, 'code', ErrorCodes.validation)
              .having((e) => e.statusCode, 'status', 422),
        ),
      );
    });
  });

  group('LocalGuidesMockDataSource - getGuide', () {
    test('fetches existing guide by id', () async {
      final guide = await dataSource.getGuide('youssef-el-nuby');
      expect(guide.fullName, 'Youssef El Nuby');
      expect(guide.isFeatured, isTrue);
    });

    test('throws 404 GUIDE_NOT_FOUND for unknown guide', () async {
      expect(
        () => dataSource.getGuide('unknown-guide-id'),
        throwsA(
          isA<AppException>()
              .having((e) => e.code, 'code', 'GUIDE_NOT_FOUND')
              .having((e) => e.statusCode, 'status', 404),
        ),
      );
    });
  });

  group('LocalGuidesMockDataSource - createGuideRequest', () {
    String futureCairoDate() {
      final nowCairo = DateTime.now().toUtc().add(const Duration(hours: 2));
      final future = nowCairo.add(const Duration(days: 5));
      return '${future.year.toString().padLeft(4, '0')}-'
          '${future.month.toString().padLeft(2, '0')}-'
          '${future.day.toString().padLeft(2, '0')}';
    }

    test('creates valid guide request returning status pending', () async {
      final req = GuideRequestCreateDto(
        guideId: 'youssef-el-nuby',
        date: futureCairoDate(),
        duration: 'one_day',
        startTime: '09:00',
        groupSize: 2,
        language: 'en',
        interests: ['nubian_culture'],
        notes: 'Testing request',
      );

      final result = await dataSource.createGuideRequest(req);
      expect(result.status, 'pending');
      expect(result.id, startsWith('req-'));

      // Check /mine list contains the request
      final mine = await dataSource.getGuideRequestsMine();
      expect(mine.data.any((r) => r.id == result.id), isTrue);
    });

    test('rejects date in the past with DATE_IN_PAST', () async {
      final pastDate = '2020-01-01';
      final req = GuideRequestCreateDto(
        guideId: 'youssef-el-nuby',
        date: pastDate,
        duration: 'one_day',
        startTime: '09:00',
        groupSize: 2,
        language: 'en',
      );

      expect(
        () => dataSource.createGuideRequest(req),
        throwsA(
          isA<AppException>()
              .having((e) => e.code, 'code', ErrorCodes.validation)
              .having((e) => e.statusCode, 'status', 422)
              .having((e) => e.details['date'], 'details.date', 'DATE_IN_PAST'),
        ),
      );
    });

    test('rejects unknown guide with 404 GUIDE_NOT_FOUND', () async {
      final req = GuideRequestCreateDto(
        guideId: 'ghost-guide',
        date: futureCairoDate(),
        duration: 'one_day',
        startTime: '09:00',
        groupSize: 2,
        language: 'en',
      );

      expect(
        () => dataSource.createGuideRequest(req),
        throwsA(
          isA<AppException>()
              .having((e) => e.code, 'code', 'GUIDE_NOT_FOUND')
              .having((e) => e.statusCode, 'status', 404),
        ),
      );
    });

    test('requires duration_hours 1..12 when duration is custom', () async {
      final reqWithoutHours = GuideRequestCreateDto(
        guideId: 'youssef-el-nuby',
        date: futureCairoDate(),
        duration: 'custom',
        durationHours: null,
        startTime: '09:00',
        groupSize: 2,
        language: 'en',
      );

      expect(
        () => dataSource.createGuideRequest(reqWithoutHours),
        throwsA(
          isA<AppException>()
              .having((e) => e.code, 'code', ErrorCodes.validation)
              .having((e) => e.statusCode, 'status', 422)
              .having(
                (e) => e.details['duration_hours'],
                'details',
                'VALIDATION_ERROR',
              ),
        ),
      );

      final reqWithValidHours = GuideRequestCreateDto(
        guideId: 'youssef-el-nuby',
        date: futureCairoDate(),
        duration: 'custom',
        durationHours: 6,
        startTime: '09:00',
        groupSize: 2,
        language: 'en',
      );

      final result = await dataSource.createGuideRequest(reqWithValidHours);
      expect(result.status, 'pending');
    });

    test('rejects invalid group size (< 1 or > 20)', () async {
      final req = GuideRequestCreateDto(
        guideId: 'youssef-el-nuby',
        date: futureCairoDate(),
        duration: 'few_hours',
        startTime: '09:00',
        groupSize: 25,
        language: 'en',
      );

      expect(
        () => dataSource.createGuideRequest(req),
        throwsA(
          isA<AppException>().having(
            (e) => e.details['group_size'],
            'group_size',
            'VALIDATION_ERROR',
          ),
        ),
      );
    });
  });

  group('LocalGuidesMockDataSource - createGuideApplication', () {
    test('submits valid guide application', () async {
      final app = GuideApplicationCreateDto(
        fullName: 'New Guide Candidate',
        languages: ['ar', 'en'],
        specialties: ['nubian_culture'],
        bio: 'Local guide applicant.',
        durations: ['few_hours', 'one_day'],
        contact: '01012345678',
        profilePhoto: 'assets/images/home/avatar_laila.jpg',
      );

      final result = await dataSource.createGuideApplication(app);
      expect(result.status, 'pending');
      expect(result.id, startsWith('app-'));
    });

    test(
      'second application with same contact throws 409 ALREADY_APPLIED',
      () async {
        final app = GuideApplicationCreateDto(
          fullName: 'Candidate One',
          languages: ['ar'],
          specialties: ['nile'],
          bio: 'Bio',
          durations: ['one_day'],
          contact: '+201099998888',
        );

        await dataSource.createGuideApplication(app);

        expect(
          () => dataSource.createGuideApplication(app),
          throwsA(
            isA<AppException>()
                .having((e) => e.code, 'code', 'ALREADY_APPLIED')
                .having((e) => e.statusCode, 'status', 409),
          ),
        );
      },
    );

    test('rejects invalid Egyptian contact number with 422', () async {
      final app = GuideApplicationCreateDto(
        fullName: 'Candidate',
        languages: ['ar'],
        specialties: ['nile'],
        bio: 'Bio',
        durations: ['one_day'],
        contact: '123456', // Invalid phone
      );

      expect(
        () => dataSource.createGuideApplication(app),
        throwsA(
          isA<AppException>().having(
            (e) => e.details['contact'],
            'contact',
            'VALIDATION_ERROR',
          ),
        ),
      );
    });

    test('rejects photo exceeding 5 MB with FILE_TOO_LARGE', () async {
      final app = GuideApplicationCreateDto(
        fullName: 'Candidate',
        languages: ['ar'],
        specialties: ['nile'],
        bio: 'Bio',
        durations: ['one_day'],
        contact: '01123456789',
        profilePhoto: 'my_file_too_large.jpg',
      );

      expect(
        () => dataSource.createGuideApplication(app),
        throwsA(
          isA<AppException>().having(
            (e) => e.details['profile_photo'],
            'photo',
            'FILE_TOO_LARGE',
          ),
        ),
      );
    });

    test(
      'rejects unsupported photo file type with UNSUPPORTED_FILE_TYPE',
      () async {
        final app = GuideApplicationCreateDto(
          fullName: 'Candidate',
          languages: ['ar'],
          specialties: ['nile'],
          bio: 'Bio',
          durations: ['one_day'],
          contact: '01223456789',
          profilePhoto: 'resume.pdf',
        );

        expect(
          () => dataSource.createGuideApplication(app),
          throwsA(
            isA<AppException>().having(
              (e) => e.details['profile_photo'],
              'photo',
              'UNSUPPORTED_FILE_TYPE',
            ),
          ),
        );
      },
    );
  });
}
