import 'package:aswani/features/places/data/mappers/place_details_mapper.dart';
import 'package:aswani/features/places/data/mappers/place_report_mapper.dart';
import 'package:aswani/features/places/data/models/place_details_dto.dart';
import 'package:aswani/features/places/data/models/place_report_dto.dart';
import 'package:aswani/features/places/domain/entities/place_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaceDetailsDto & PlaceFactDto serialization', () {
    test('wraps Sprint 1 place and adds all Sprint 2 fields', () {
      final json = {
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
        'image': 'assets/images/places/philae_temple.jpg',
        'is_curated': true,
        'is_editors_pick': true,
        'is_bookmarked': false,
        'location_en': 'Agilkia Island, Aswan',
        'location_ar': 'جزيرة أجيليكيا، أسوان',
        'about_en': 'An archaeological complex on an island in the Nile.',
        'about_ar': 'مجمع أثري على جزيرة في النيل.',
        'images': [
          'assets/images/places/philae_temple.jpg',
          'assets/images/places/philae_temple.jpg',
        ],
        'facts': [
          {
            'type': 'access',
            'label_en': 'Boat access',
            'label_ar': 'الوصول بالقارب',
          },
          {
            'type': 'hours',
            'label_en': 'Check before visiting',
            'label_ar': 'تحقق قبل الزيارة',
          },
        ],
      };

      final dto = PlaceDetailsDto.fromJson(json);
      expect(dto.place.id, 'philae');
      expect(dto.place.nameEn, 'Philae Temple');
      expect(dto.locationEn, 'Agilkia Island, Aswan');
      expect(dto.locationAr, 'جزيرة أجيليكيا، أسوان');
      expect(dto.images.length, 2);
      expect(dto.facts.length, 2);
      expect(dto.facts.first.type, 'access');

      final serialized = dto.toJson();
      expect(serialized['id'], 'philae');
      expect(serialized['location_en'], 'Agilkia Island, Aswan');
      expect(serialized['facts'].length, 2);

      final entity = dto.toEntity();
      expect(entity.id, 'philae');
      expect(entity.name('en'), 'Philae Temple');
      expect(entity.name('ar'), 'معبد فيلة');
      expect(entity.location('en'), 'Agilkia Island, Aswan');
      expect(entity.location('ar'), 'جزيرة أجيليكيا، أسوان');
      expect(
        entity.about('en'),
        'An archaeological complex on an island in the Nile.',
      );
      expect(entity.facts.first.label('ar'), 'الوصول بالقارب');
    });
  });

  group('PlaceReport DTO serialization', () {
    // The photo is a multipart file, so it is not part of the JSON fields.
    test('PlaceReportCreateDto serializes multipart fields', () {
      final json = {
        'place_id': 'philae',
        'reason': 'incorrect_information',
        'details': 'Opening hours have changed recently.',
      };

      final dto = PlaceReportCreateDto.fromJson(json);
      expect(dto.placeId, 'philae');
      expect(dto.reason, 'incorrect_information');
      expect(dto.details, 'Opening hours have changed recently.');
      expect(dto.toJson(), json);
    });

    test('PlaceReportResultDto parses 201 response with 25 points_pending', () {
      final json = {'id': 'rep-1', 'status': 'pending', 'points_pending': 25};

      final dto = PlaceReportResultDto.fromJson(json);
      expect(dto.id, 'rep-1');
      expect(dto.status, 'pending');
      expect(dto.pointsPending, 25);
      expect(dto.toJson(), json);

      final entity = dto.toEntity();
      expect(entity.id, 'rep-1');
      expect(entity.status, 'pending');
      expect(entity.pointsPending, 25);
    });

    test('PlaceReportItemDto parses /mine item', () {
      final json = {
        'id': 'rep-1',
        'place': {
          'id': 'philae',
          'name_en': 'Philae Temple',
          'name_ar': 'معبد فيلة',
          'image': 'assets/images/places/philae_temple.jpg',
        },
        'reason': 'incorrect_location',
        'status': 'pending',
        'points_awarded': null,
        'created_at': '2026-11-20T12:00:00Z',
      };

      final dto = PlaceReportItemDto.fromJson(json);
      expect(dto.place.nameEn, 'Philae Temple');
      expect(dto.reason, 'incorrect_location');
      expect(dto.pointsAwarded, isNull);

      final entity = dto.toEntity();
      expect(entity.place.name('ar'), 'معبد فيلة');
      expect(entity.reason, PlaceReportReason.incorrectLocation);
      expect(entity.status, 'pending');
    });
  });
}
