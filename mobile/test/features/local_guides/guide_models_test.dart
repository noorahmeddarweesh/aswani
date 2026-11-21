import 'package:aswani/features/local_guides/data/mappers/guide_application_mapper.dart';
import 'package:aswani/features/local_guides/data/mappers/guide_mapper.dart';
import 'package:aswani/features/local_guides/data/mappers/guide_request_mapper.dart';
import 'package:aswani/features/local_guides/data/models/guide_application_dto.dart';
import 'package:aswani/features/local_guides/data/models/guide_dto.dart';
import 'package:aswani/features/local_guides/data/models/guide_request_dto.dart';
import 'package:aswani/features/local_guides/data/models/page_meta_dto.dart';
import 'package:aswani/features/local_guides/domain/entities/guide_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GuideDto serialization & mapping', () {
    test('serializes and deserializes exact snake_case contract fields', () {
      final json = {
        'id': 'youssef-el-nuby',
        'full_name': 'Youssef El Nuby',
        'photo': 'https://example.com/photos/youssef.jpg',
        'city': 'Aswan',
        'tagline': 'Nubian stories • History walks • Arabic & English',
        'languages': ['ar', 'en'],
        'specialties': ['nubian_culture', 'historical_sites'],
        'bio': 'Passionate about local stories.',
        'durations': ['few_hours', 'one_day', 'multiple_days'],
        'is_featured': true,
        'is_verified': false,
      };

      final dto = GuideDto.fromJson(json);
      expect(dto.id, 'youssef-el-nuby');
      expect(dto.fullName, 'Youssef El Nuby');
      expect(dto.photo, 'https://example.com/photos/youssef.jpg');
      expect(dto.city, 'Aswan');
      expect(dto.tagline, 'Nubian stories • History walks • Arabic & English');
      expect(dto.languages, ['ar', 'en']);
      expect(dto.specialties, ['nubian_culture', 'historical_sites']);
      expect(dto.bio, 'Passionate about local stories.');
      expect(dto.durations, ['few_hours', 'one_day', 'multiple_days']);
      expect(dto.isFeatured, isTrue);
      expect(dto.isVerified, isFalse);

      final serialized = dto.toJson();
      expect(serialized, json);

      final entity = dto.toEntity();
      expect(entity.id, dto.id);
      expect(entity.fullName, dto.fullName);
      expect(entity.languages, [GuideLanguage.ar, GuideLanguage.en]);
      expect(entity.specialties, [
        GuideSpecialty.nubianCulture,
        GuideSpecialty.historicalSites,
      ]);
      expect(entity.durations, [
        GuideDuration.fewHours,
        GuideDuration.oneDay,
        GuideDuration.multipleDays,
      ]);
      expect(entity.isFeatured, isTrue);
      expect(entity.isVerified, isFalse);
    });

    test('supports nullable photo', () {
      final json = {
        'id': 'guide-2',
        'full_name': 'No Photo Guide',
        'photo': null,
        'city': 'Aswan',
        'tagline': 'Tagline',
        'languages': ['ar'],
        'specialties': ['nile'],
        'bio': 'Bio',
        'durations': ['one_day'],
        'is_featured': false,
        'is_verified': false,
      };

      final dto = GuideDto.fromJson(json);
      expect(dto.photo, isNull);
      expect(dto.toEntity().photo, isNull);
    });
  });

  group('GuideRequest DTO serialization & mapping', () {
    test('GuideRequestCreateDto handles all contract fields', () {
      final json = {
        'guide_id': 'youssef-el-nuby',
        'date': '2026-12-01',
        'duration': 'custom',
        'duration_hours': 6,
        'start_time': '09:00',
        'group_size': 4,
        'language': 'en',
        'interests': ['nubian_culture', 'nile'],
        'notes': 'Looking forward to the tour.',
      };

      final dto = GuideRequestCreateDto.fromJson(json);
      expect(dto.guideId, 'youssef-el-nuby');
      expect(dto.durationHours, 6);
      expect(dto.notes, 'Looking forward to the tour.');
      expect(dto.toJson(), json);
    });

    test('GuideRequestResultDto parses 201 response', () {
      final json = {'id': 'req-123', 'status': 'pending'};
      final dto = GuideRequestResultDto.fromJson(json);
      expect(dto.id, 'req-123');
      expect(dto.status, 'pending');
      expect(dto.toJson(), json);

      final entity = dto.toEntity();
      expect(entity.id, 'req-123');
      expect(entity.status, RequestStatus.pending);
    });

    test('GuideRequestItemDto parses /mine list item', () {
      final json = {
        'id': 'req-1',
        'guide': {
          'id': 'youssef-el-nuby',
          'full_name': 'Youssef El Nuby',
          'photo': 'https://example.com/p.jpg',
        },
        'date': '2026-12-01',
        'duration': 'one_day',
        'duration_hours': null,
        'start_time': '10:00',
        'group_size': 2,
        'language': 'ar',
        'interests': ['nubian_culture'],
        'status': 'pending',
        'created_at': '2026-11-20T10:00:00Z',
      };

      final dto = GuideRequestItemDto.fromJson(json);
      expect(dto.guide.fullName, 'Youssef El Nuby');
      expect(dto.language, 'ar');
      expect(dto.status, 'pending');

      final entity = dto.toEntity();
      expect(entity.guide.fullName, 'Youssef El Nuby');
      expect(entity.duration, RequestDuration.oneDay);
      expect(entity.status, RequestStatus.pending);
    });
  });

  group('GuideApplication DTO serialization & mapping', () {
    test('GuideApplicationCreateDto serializes multipart fields', () {
      final json = {
        'full_name': 'Mariam Ahmed',
        'languages': ['ar', 'en'],
        'specialties': ['nubian_culture', 'local_experiences'],
        'bio': 'Passionate explorer.',
        'durations': ['few_hours', 'one_day'],
        'contact': '01012345678',
        'profile_photo': 'path/to/photo.jpg',
      };

      final dto = GuideApplicationCreateDto.fromJson(json);
      expect(dto.fullName, 'Mariam Ahmed');
      expect(dto.contact, '01012345678');
      expect(dto.toJson(), json);
    });

    test('GuideApplicationResultDto parses response', () {
      final json = {'id': 'app-1', 'status': 'pending'};
      final dto = GuideApplicationResultDto.fromJson(json);
      expect(dto.id, 'app-1');
      expect(dto.status, 'pending');
      expect(dto.toEntity().status, RequestStatus.pending);
    });
  });

  group('PageMetaDto', () {
    test('parses and calculates pagination correctly', () {
      final json = {
        'page': 1,
        'limit': 20,
        'total': 45,
        'total_pages': 3,
      };

      final dto = PageMetaDto.fromJson(json);
      expect(dto.page, 1);
      expect(dto.totalPages, 3);
      expect(dto.toJson(), json);

      final entity = dto.toEntity();
      expect(entity.hasNextPage, isTrue);
      expect(entity.hasPreviousPage, isFalse);
    });
  });
}
