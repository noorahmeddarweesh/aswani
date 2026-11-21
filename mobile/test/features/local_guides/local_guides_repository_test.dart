import 'package:aswani/core/result/result.dart';
import 'package:aswani/features/local_guides/data/datasources/local_guides_mock_datasource.dart';
import 'package:aswani/features/local_guides/data/repositories/local_guides_repository_impl.dart';
import 'package:aswani/features/local_guides/domain/entities/guide.dart';
import 'package:aswani/features/local_guides/domain/entities/guide_application.dart';
import 'package:aswani/features/local_guides/domain/entities/guide_enums.dart';
import 'package:aswani/features/local_guides/domain/entities/guide_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalGuidesRepositoryImpl repository;

  setUp(() {
    repository = LocalGuidesRepositoryImpl(
      LocalGuidesMockDataSource(delay: Duration.zero),
    );
  });

  group('LocalGuidesRepositoryImpl', () {
    test('getGuides returns domain entities and meta', () async {
      final result = await repository.getGuides();
      expect(result, isA<Success>());
      final paged = (result as Success).value;
      expect(paged.data.length, 3);
      expect(paged.data.first, isA<Guide>());
      expect(paged.data.first.fullName, 'Youssef El Nuby');
      expect(paged.meta.total, 3);
    });

    test('getGuide returns single guide entity', () async {
      final result = await repository.getGuide('youssef-el-nuby');
      expect(result, isA<Success>());
      final guide = (result as Success).value;
      expect(guide.id, 'youssef-el-nuby');
      expect(guide.isFeatured, isTrue);
    });

    test('getGuide returns Error for non-existent guide', () async {
      final result = await repository.getGuide('non-existent');
      expect(result, isA<Error>());
      final error = result as Error;
      expect(error.failure.code, 'GUIDE_NOT_FOUND');
    });

    test('createGuideRequest and getGuideRequestsMine flow', () async {
      final nowCairo = DateTime.now().toUtc().add(const Duration(hours: 2));
      final futureDate = nowCairo.add(const Duration(days: 3));
      final dateStr =
          '${futureDate.year.toString().padLeft(4, '0')}-'
          '${futureDate.month.toString().padLeft(2, '0')}-'
          '${futureDate.day.toString().padLeft(2, '0')}';

      final request = GuideRequestCreate(
        guideId: 'youssef-el-nuby',
        date: dateStr,
        duration: RequestDuration.oneDay,
        startTime: '10:00',
        groupSize: 3,
        language: GuideLanguage.en,
        interests: [GuideSpecialty.historicalSites],
      );

      final result = await repository.createGuideRequest(request);
      expect(result, isA<Success>());
      final created = (result as Success).value;
      expect(created.status, RequestStatus.pending);

      final mineResult = await repository.getGuideRequestsMine();
      expect(mineResult, isA<Success>());
      final mine = (mineResult as Success).value;
      expect(mine.data.any((r) => r.id == created.id), isTrue);
      final item = mine.data.firstWhere((r) => r.id == created.id);
      expect(item.guide.fullName, 'Youssef El Nuby');
      expect(item.groupSize, 3);
      expect(item.duration, RequestDuration.oneDay);
    });

    test('createGuideApplication flow and duplicate prevention', () async {
      final app = GuideApplicationCreate(
        fullName: 'Ahmed Guide',
        languages: [GuideLanguage.ar, GuideLanguage.en],
        specialties: [GuideSpecialty.nile],
        bio: 'Local explorer and storyteller.',
        durations: [GuideDuration.fewHours],
        contact: '01001122334',
      );

      final result = await repository.createGuideApplication(app);
      expect(result, isA<Success>());
      final success = (result as Success).value;
      expect(success.status, RequestStatus.pending);

      // Repeat application with same contact
      final duplicate = await repository.createGuideApplication(app);
      expect(duplicate, isA<Error>());
      expect((duplicate as Error).failure.code, 'ALREADY_APPLIED');
    });
  });
}
