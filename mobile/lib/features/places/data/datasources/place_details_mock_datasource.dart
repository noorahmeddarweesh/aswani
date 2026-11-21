import 'package:aswani/core/assets/app_images.dart';
import 'package:aswani/core/errors/app_exception.dart';
import 'package:aswani/core/errors/failure.dart';
import 'package:aswani/features/local_guides/data/models/page_meta_dto.dart';

import '../../../../core/network/upload.dart';
import '../models/place_details_dto.dart';
import '../models/place_report_dto.dart';
import 'place_details_datasource.dart';

/// In-memory mock implementation of PlaceDetailsDataSource per API Contract v0.2.
/// ALL mock data below are illustrative prototype records for testing and design fidelity;
/// they do NOT represent real or official backend data.
class PlaceDetailsMockDataSource implements PlaceDetailsDataSource {
  PlaceDetailsMockDataSource({this.delay = const Duration(milliseconds: 150)});

  final Duration delay;

  // In-memory submitted reports for /mine endpoint.
  final List<Map<String, dynamic>> _reports = [];

  // Seed data extending Sprint 1 places with Contract v0.2 details.
  static final Map<String, Map<String, dynamic>> _seedPlaceDetails = {
    'philae': {
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
      'image': AppImages.philaeTemple,
      'is_curated': true,
      'is_editors_pick': true,
      'is_bookmarked': false,
      'location_en': 'Agilkia Island, Aswan',
      'location_ar': 'جزيرة أجيليكيا، أسوان',
      'about_en':
          'An archaeological complex on an island in the Nile. This prototype summary is '
          'illustrative; historical details and visiting information should be reviewed '
          'against official sources before publishing.',
      'about_ar':
          'مجمع أثري على جزيرة في النيل. هذا الملخص النموذجي توضيحي؛ ينبغي مراجعة التفاصيل '
          'التاريخية ومعلومات الزيارة مع المصادر الرسمية قبل النشر.',
      'images': [
        AppImages.philaeTemple,
        AppImages.philaeTemple,
        AppImages.philaeTemple,
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
    },
    'nubian-village': {
      'id': 'nubian-village',
      'category': 'nubian',
      'name_en': 'Nubian Village',
      'name_ar': 'القرية النوبية',
      'label_en': 'Local culture',
      'label_ar': 'ثقافة محلية',
      'tagline_en': 'Colours, music and hospitality',
      'tagline_ar': 'ألوان وموسيقى وكرم ضيافة',
      'city_en': 'Aswan',
      'city_ar': 'أسوان',
      'image': AppImages.nubianVillage,
      'is_curated': true,
      'is_editors_pick': false,
      'is_bookmarked': false,
      'location_en': 'West Bank, Aswan',
      'location_ar': 'الضفة الغربية، أسوان',
      'about_en':
          'Vibrant Nubian community known for brightly colored homes, handcrafted goods, '
          'and warm Nile hospitality. Prototype summary.',
      'about_ar': 'مجتمع نوبي نابض بالحياة يشتهر بالمنازل الملونة والمشغولات اليدوية وكرم ضيافة النيل. ملخص توضيحي.',
      'images': [AppImages.nubianVillage, AppImages.nubianVillage],
      'facts': [
        {
          'type': 'access',
          'label_en': 'Felucca or motorboat',
          'label_ar': 'فلوكة أو قارب بمحرك',
        },
        {
          'type': 'hours',
          'label_en': 'Daytime visits recommended',
          'label_ar': 'يُفضل الزيارة نهارًا',
        },
      ],
    },
    'elephantine': {
      'id': 'elephantine',
      'category': 'nature',
      'name_en': 'Elephantine Island',
      'name_ar': 'جزيرة إلفنتين',
      'label_en': 'Nature & local life',
      'label_ar': 'طبيعة وحياة محلية',
      'tagline_en': 'Nile & local life',
      'tagline_ar': 'النيل والحياة المحلية',
      'city_en': 'Aswan',
      'city_ar': 'أسوان',
      'image': AppImages.elephantineIsland,
      'is_curated': true,
      'is_editors_pick': false,
      'is_bookmarked': false,
      'location_en': 'Center of the Nile, Aswan',
      'location_ar': 'وسط النيل، أسوان',
      'about_en':
          'An island steeped in ancient Egyptian history, home to ancient nilometers, '
          'lush gardens, and Nubian hamlets. Prototype summary.',
      'about_ar': 'جزيرة عريقة في التاريخ المصري القديم، تضم مقاييس نيلية قديمة وحدائق وقرى نوبية هادئة. ملخص توضيحي.',
      'images': [AppImages.elephantineIsland],
      'facts': [
        {
          'type': 'access',
          'label_en': 'Local public ferry',
          'label_ar': 'معدية عامة محلية',
        },
        {'type': 'hours', 'label_en': 'Open daily', 'label_ar': 'مفتوح يوميًا'},
      ],
    },
    'nubian-museum': {
      'id': 'nubian-museum',
      'category': 'history',
      'name_en': 'Nubian Museum',
      'name_ar': 'متحف النوبة',
      'label_en': 'Heritage & history',
      'label_ar': 'تراث وتاريخ',
      'tagline_en': 'The story of Nubia',
      'tagline_ar': 'حكاية النوبة',
      'city_en': 'Aswan',
      'city_ar': 'أسوان',
      'image': AppImages.nubianMuseum,
      'is_curated': false,
      'is_editors_pick': false,
      'is_bookmarked': false,
      'location_en': 'Sheyakhah Thalethah, Aswan',
      'location_ar': 'الشياخة الثالثة، أسوان',
      'about_en':
          'Showcasing monuments and artifacts salvaged from Nubian civilization during '
          'the building of the Aswan Dam. Prototype summary.',
      'about_ar': 'يعرض الآثار والقطع التي تم إنقاذها من الحضارة النوبية أثناء بناء سد أسوان. ملخص توضيحي.',
      'images': [AppImages.nubianMuseum],
      'facts': [
        {
          'type': 'access',
          'label_en': 'Road access (taxis & walking)',
          'label_ar': 'طريق بري (تاكسي أو سيرًا)',
        },
        {
          'type': 'hours',
          'label_en': 'Morning & evening sessions',
          'label_ar': 'فترات صباحية ومسائية',
        },
      ],
    },
  };

  @override
  Future<PlaceDetailsDto> getPlaceDetails(String id) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);

    final detailsJson = _seedPlaceDetails[id];
    if (detailsJson == null) {
      throw const AppException(
        code: ErrorCodes.placeNotFound,
        statusCode: 404,
        message: 'Place not found with id',
      );
    }
    return PlaceDetailsDto.fromJson(detailsJson);
  }

  @override
  Future<PlaceReportResultDto> createPlaceReport(
    PlaceReportCreateDto report,
  ) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);

    // Validate place existence
    final placeJson = _seedPlaceDetails[report.placeId];
    if (placeJson == null) {
      throw const AppException(
        code: ErrorCodes.placeNotFound,
        statusCode: 404,
        message: 'Place not found for reporting',
      );
    }

    // Validate reason enum
    const allowedReasons = [
      'not_exist',
      'permanently_closed',
      'temporarily_closed',
      'incorrect_location',
      'incorrect_information',
      'other',
    ];
    if (!allowedReasons.contains(report.reason)) {
      throw const AppException(
        code: ErrorCodes.validation,
        statusCode: 422,
        details: {'reason': 'VALIDATION_ERROR'},
        message: 'Invalid report reason',
      );
    }

    // Validate details: required, 1..1000 characters
    final trimmedDetails = report.details.trim();
    if (trimmedDetails.isEmpty || report.details.length > 1000) {
      throw const AppException(
        code: ErrorCodes.validation,
        statusCode: 422,
        details: {'details': 'VALIDATION_ERROR'},
        message: 'Report details must be between 1 and 1000 characters',
      );
    }

    // Validate photo if given
    if (report.photo case final photo?) {
      _validatePhoto(photo, 'photo');
    }

    final newId = 'rep-${_reports.length + 1}';
    final createdAt = DateTime.now().toUtc().toIso8601String();

    _reports.insert(0, {
      'id': newId,
      'place': {
        'id': placeJson['id'],
        'name_en': placeJson['name_en'],
        'name_ar': placeJson['name_ar'],
        'image': placeJson['image'],
      },
      'reason': report.reason,
      'status': 'pending',
      'points_awarded': null,
      'created_at': createdAt,
    });

    return PlaceReportResultDto(
      id: newId,
      status: 'pending',
      pointsPending: 25,
    );
  }

  @override
  Future<PagedListDto<PlaceReportItemDto>> getPlaceReportsMine({
    int page = 1,
    int limit = 20,
  }) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);

    if (page < 1 || limit < 1 || limit > 50) {
      throw const AppException(
        code: ErrorCodes.validation,
        statusCode: 422,
        details: {'pagination': 'VALIDATION_ERROR'},
        message: 'Invalid pagination parameters',
      );
    }

    final total = _reports.length;
    final totalPages = (total / limit).ceil().clamp(1, 9999);
    final startIndex = (page - 1) * limit;

    final items = startIndex < total
        ? _reports
              .skip(startIndex)
              .take(limit)
              .map(PlaceReportItemDto.fromJson)
              .toList()
        : <PlaceReportItemDto>[];

    return PagedListDto<PlaceReportItemDto>(
      data: items,
      meta: PageMetaDto(
        page: page,
        limit: limit,
        total: total,
        totalPages: totalPages,
      ),
    );
  }

  void _validatePhoto(UploadFile photo, String fieldName) {
    final problem = checkUpload(photo);
    if (problem != null) {
      throw AppException(
        code: ErrorCodes.validation,
        statusCode: 422,
        details: {fieldName: problem},
      );
    }
  }
}
