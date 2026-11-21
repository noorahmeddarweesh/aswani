import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../models/guide_application_dto.dart';
import '../models/guide_dto.dart';
import '../models/guide_request_dto.dart';
import '../models/page_meta_dto.dart';
import 'local_guides_datasource.dart';

/// In-memory mock implementation of LocalGuidesDataSource per API Contract v0.2.
/// ALL mock and sample data below are strictly illustrative mock profiles
/// created for prototype testing and design fidelity; they do NOT represent
/// real API data or verified credentials.
class LocalGuidesMockDataSource implements LocalGuidesDataSource {
  LocalGuidesMockDataSource({this.delay = const Duration(milliseconds: 150)});

  final Duration delay;

  // Track applied contacts to test 409 ALREADY_APPLIED.
  final Set<String> _appliedContacts = {};

  // In-memory submitted requests for /mine endpoint.
  final List<Map<String, dynamic>> _requests = [];

  /// Resets in-memory state for clean testing.
  void reset() {
    _appliedContacts.clear();
    _requests.clear();
  }

  // Seed sample guides (strictly illustrative prototypes).
  static final List<Map<String, dynamic>> _seedGuides = [
    {
      'id': 'youssef-el-nuby',
      'full_name': 'Youssef El Nuby',
      'photo': 'assets/images/places/philae_temple.jpg',
      'city': 'Aswan',
      'tagline': 'Nubian stories • History walks • Arabic & English',
      'languages': ['ar', 'en'],
      'specialties': [
        'nubian_culture',
        'historical_sites',
        'local_experiences',
      ],
      'bio':
          'Passionate about local stories, Nubian architecture, and Nile experiences. '
          'Details on this profile are illustrative and do not indicate official credentials.',
      'durations': ['few_hours', 'one_day', 'multiple_days'],
      'is_featured': true,
      'is_verified': false,
    },
    {
      'id': 'mariam-ahmed',
      'full_name': 'Mariam Ahmed',
      'photo': 'assets/images/home/mariam.jpg',
      'city': 'Aswan',
      'tagline': 'Local & family experiences',
      'languages': ['ar', 'en'],
      'specialties': ['nubian_culture', 'local_experiences'],
      'bio':
          'Certified explorer with rich stories of Nubian traditions, family heritage, '
          'and riverside experiences. Illustrative profile.',
      'durations': ['few_hours', 'one_day'],
      'is_featured': false,
      'is_verified': false,
    },
    {
      'id': 'ahmed-salem',
      'full_name': 'Ahmed Salem',
      'photo': 'assets/images/places/philae_temple.jpg',
      'city': 'Aswan',
      'tagline': 'Nile & photography',
      'languages': ['ar', 'en'],
      'specialties': ['nile', 'photography'],
      'bio':
          'Capturing the timeless beauty of Aswan and the Nile through light, shadows, '
          'and river boat journeys. Illustrative profile.',
      'durations': ['few_hours', 'one_day', 'multiple_days'],
      'is_featured': false,
      'is_verified': false,
    },
  ];

  static final RegExp _egyptPhone = RegExp(r'^(\+20|0020|0)?1[0125]\d{8}$');
  static final RegExp _timeFormat = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');
  static final RegExp _dateFormat = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  @override
  Future<PagedListDto<GuideDto>> getGuides({
    String? specialty,
    String? q,
    int page = 1,
    int limit = 20,
  }) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);

    if (page < 1 || limit < 1 || limit > 50) {
      throw const AppException(
        code: ErrorCodes.validation,
        statusCode: 422,
        details: {'pagination': 'VALIDATION_ERROR'},
        message: 'Invalid pagination parameters. Page >= 1, 1 <= limit <= 50',
      );
    }

    final filtered = _seedGuides.where((g) {
      if (specialty != null && specialty.isNotEmpty) {
        final specs = (g['specialties'] as List<dynamic>?) ?? [];
        if (!specs.contains(specialty)) return false;
      }
      if (q != null && q.trim().isNotEmpty) {
        final query = q.trim().toLowerCase();
        final name = (g['full_name'] as String? ?? '').toLowerCase();
        final specs = ((g['specialties'] as List<dynamic>?) ?? []).map(
          (e) => e.toString().toLowerCase(),
        );
        final matchesName = name.contains(query);
        final matchesSpec = specs.any((s) => s.contains(query));
        if (!matchesName && !matchesSpec) return false;
      }
      return true;
    }).toList();

    final total = filtered.length;
    final totalPages = (total / limit).ceil().clamp(1, 9999);
    final startIndex = (page - 1) * limit;

    final items = startIndex < total
        ? filtered.skip(startIndex).take(limit).map(GuideDto.fromJson).toList()
        : <GuideDto>[];

    return PagedListDto<GuideDto>(
      data: items,
      meta: PageMetaDto(
        page: page,
        limit: limit,
        total: total,
        totalPages: totalPages,
      ),
    );
  }

  @override
  Future<GuideDto> getGuide(String id) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);

    final guideJson = _seedGuides.where((g) => g['id'] == id).firstOrNull;
    if (guideJson == null) {
      throw AppException(
        code: 'GUIDE_NOT_FOUND',
        statusCode: 404,
        message: 'Guide not found with id $id',
      );
    }
    return GuideDto.fromJson(guideJson);
  }

  @override
  Future<GuideRequestResultDto> createGuideRequest(
    GuideRequestCreateDto request,
  ) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);

    // Validate guide existence
    final guide = _seedGuides
        .where((g) => g['id'] == request.guideId)
        .firstOrNull;
    if (guide == null) {
      throw const AppException(
        code: 'GUIDE_NOT_FOUND',
        statusCode: 404,
        message: 'Guide not found',
      );
    }

    // Validate date format & Cairo time (UTC+2)
    if (!_dateFormat.hasMatch(request.date)) {
      throw const AppException(
        code: ErrorCodes.validation,
        statusCode: 422,
        details: {'date': 'VALIDATION_ERROR'},
        message: 'Date must be formatted as YYYY-MM-DD',
      );
    }

    final nowCairo = DateTime.now().toUtc().add(const Duration(hours: 2));
    final todayCairo =
        '${nowCairo.year.toString().padLeft(4, '0')}-'
        '${nowCairo.month.toString().padLeft(2, '0')}-'
        '${nowCairo.day.toString().padLeft(2, '0')}';
    if (request.date.compareTo(todayCairo) < 0) {
      throw const AppException(
        code: ErrorCodes.validation,
        statusCode: 422,
        details: {'date': 'DATE_IN_PAST'},
        message: 'Request date cannot be in the past',
      );
    }

    // Validate duration & duration_hours
    const allowedDurations = [
      'few_hours',
      'one_day',
      'two_days',
      'three_days',
      'custom',
    ];
    if (!allowedDurations.contains(request.duration)) {
      throw const AppException(
        code: ErrorCodes.validation,
        statusCode: 422,
        details: {'duration': 'VALIDATION_ERROR'},
      );
    }

    if (request.duration == 'custom') {
      if (request.durationHours == null ||
          request.durationHours! < 1 ||
          request.durationHours! > 12) {
        throw const AppException(
          code: ErrorCodes.validation,
          statusCode: 422,
          details: {'duration_hours': 'VALIDATION_ERROR'},
          message: 'duration_hours 1..12 is REQUIRED with custom duration',
        );
      }
    } else if (request.durationHours != null) {
      if (request.durationHours! < 1 || request.durationHours! > 12) {
        throw const AppException(
          code: ErrorCodes.validation,
          statusCode: 422,
          details: {'duration_hours': 'VALIDATION_ERROR'},
        );
      }
    }

    // Validate start_time (HH:mm)
    if (!_timeFormat.hasMatch(request.startTime)) {
      throw const AppException(
        code: ErrorCodes.validation,
        statusCode: 422,
        details: {'start_time': 'VALIDATION_ERROR'},
        message: 'start_time must be in HH:mm format',
      );
    }

    // Validate group_size (1..20)
    if (request.groupSize < 1 || request.groupSize > 20) {
      throw const AppException(
        code: ErrorCodes.validation,
        statusCode: 422,
        details: {'group_size': 'VALIDATION_ERROR'},
        message: 'group_size must be between 1 and 20',
      );
    }

    // Validate language
    const allowedLangs = ['ar', 'en', 'fr', 'de', 'it', 'es'];
    if (!allowedLangs.contains(request.language)) {
      throw const AppException(
        code: ErrorCodes.validation,
        statusCode: 422,
        details: {'language': 'VALIDATION_ERROR'},
      );
    }

    final newId = 'req-${_requests.length + 1}';
    final createdAt = DateTime.now().toUtc().toIso8601String();

    _requests.add({
      'id': newId,
      'guide': {
        'id': guide['id'],
        'full_name': guide['full_name'],
        'photo': guide['photo'],
      },
      'date': request.date,
      'duration': request.duration,
      'duration_hours': request.durationHours,
      'start_time': request.startTime,
      'group_size': request.groupSize,
      'language': request.language,
      'interests': request.interests ?? <String>[],
      'status': 'pending',
      'created_at': createdAt,
    });

    return GuideRequestResultDto(id: newId, status: 'pending');
  }

  @override
  Future<PagedListDto<GuideRequestItemDto>> getGuideRequestsMine({
    int page = 1,
    int limit = 20,
  }) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);

    final total = _requests.length;
    final totalPages = (total / limit).ceil().clamp(1, 9999);
    final startIndex = (page - 1) * limit;

    final items = startIndex < total
        ? _requests
              .skip(startIndex)
              .take(limit)
              .map(GuideRequestItemDto.fromJson)
              .toList()
        : <GuideRequestItemDto>[];

    return PagedListDto<GuideRequestItemDto>(
      data: items,
      meta: PageMetaDto(
        page: page,
        limit: limit,
        total: total,
        totalPages: totalPages,
      ),
    );
  }

  @override
  Future<GuideApplicationResultDto> createGuideApplication(
    GuideApplicationCreateDto application,
  ) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);

    if (application.fullName.trim().isEmpty) {
      throw const AppException(
        code: ErrorCodes.validation,
        statusCode: 422,
        details: {'full_name': 'VALIDATION_ERROR'},
      );
    }

    // Validate Egyptian mobile number
    final digits = application.contact.replaceAll(RegExp(r'[\s-]'), '');
    if (!_egyptPhone.hasMatch(digits)) {
      throw const AppException(
        code: ErrorCodes.validation,
        statusCode: 422,
        details: {'contact': 'VALIDATION_ERROR'},
        message: 'contact must be a valid Egyptian mobile number',
      );
    }

    // Check 409 ALREADY_APPLIED
    if (_appliedContacts.contains(digits)) {
      throw const AppException(
        code: 'ALREADY_APPLIED',
        statusCode: 409,
        message: 'An application with this mobile number already exists',
      );
    }

    // Validate photo if given
    if (application.profilePhoto != null &&
        application.profilePhoto!.isNotEmpty) {
      _validatePhoto(application.profilePhoto!, 'profile_photo');
    }

    _appliedContacts.add(digits);
    final id = 'app-${_appliedContacts.length}';
    return GuideApplicationResultDto(id: id, status: 'pending');
  }

  void _validatePhoto(String photoPathOrUrl, String fieldName) {
    final lower = photoPathOrUrl.toLowerCase();
    // Simulate size limit check (file naming test convention: _too_large or > 5MB)
    if (lower.contains('too_large') || lower.contains('file_too_large')) {
      throw AppException(
        code: ErrorCodes.validation,
        statusCode: 422,
        details: {fieldName: 'FILE_TOO_LARGE'},
        message: 'File size exceeds 5 MB limit',
      );
    }

    final hasValidExt =
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');

    if (!hasValidExt) {
      throw AppException(
        code: ErrorCodes.validation,
        statusCode: 422,
        details: {fieldName: 'UNSUPPORTED_FILE_TYPE'},
        message: 'Only jpg, png, and webp files are supported',
      );
    }
  }
}
