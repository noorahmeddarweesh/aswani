import '../../../../core/assets/app_images.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/upload.dart';
import '../../../../core/pagination/paged.dart';
import 'profile_datasource.dart';

/// In-memory stand-in for the backend: Laila's profile from the designs.
class ProfileMockDataSource implements ProfileDataSource {
  ProfileMockDataSource({
    this.delay = const Duration(milliseconds: 400),
    this.pageSize = kPageSize,
  });

  final Duration delay;
  final int pageSize;

  String? _avatar = AppImages.avatarLaila;
  var _settings = <String, dynamic>{
    'language': 'en',
    'notifications_enabled': true,
  };
  bool _deletionRequested = false;

  /// Last PATCH body, for tests.
  Map<String, dynamic>? lastSettingsPatch;

  static const _places = [
    {
      'id': 'philae',
      'name_en': 'Philae Temple',
      'name_ar': 'معبد فيلة',
      'label_en': 'Heritage & history',
      'label_ar': 'تراث وتاريخ',
      'image': AppImages.philaeTemple,
    },
    {
      'id': 'nubian-village',
      'name_en': 'Nubian Village',
      'name_ar': 'القرية النوبية',
      'label_en': 'Local culture',
      'label_ar': 'ثقافة محلية',
      'image': AppImages.nubianVillage,
    },
    {
      'id': 'elephantine',
      'name_en': 'Elephantine Island',
      'name_ar': 'جزيرة الفنتين',
      'label_en': 'Nature & local life',
      'label_ar': 'طبيعة وحياة محلية',
      'image': AppImages.elephantineIsland,
    },
    {
      'id': 'nubian-museum',
      'name_en': 'Nubian Museum',
      'name_ar': 'متحف النوبة',
      'label_en': 'Heritage & history',
      'label_ar': 'تراث وتاريخ',
      'image': AppImages.nubianMuseum,
    },
  ];

  static const _stories = [
    {
      'id': 's_homes',
      'title_en': 'Homes that speak in color',
      'title_ar': 'بيوت تتكلم بالألوان',
      'label_en': 'Nubian heritage',
      'label_ar': 'تراث نوبي',
      'cover_image': AppImages.nubianVillage,
    },
    {
      'id': 's_nile',
      'title_en': "The Nile in Aswan's memory",
      'title_ar': 'النيل في ذاكرة أسوان',
      'label_en': 'Local life',
      'label_ar': 'حياة محلية',
      'cover_image': AppImages.homeHero,
    },
    {
      'id': 's_walls',
      'title_en': 'Walls painted by hand',
      'title_ar': 'جدران مرسومة باليد',
      'label_en': 'Arts & crafts',
      'label_ar': 'فنون وحِرف',
      'cover_image': AppImages.homeStory,
    },
  ];

  /// Newest first, as the API returns them.
  List<Map<String, dynamic>> get _saved => [
    {'type': 'place', 'place': _places[0]},
    {'type': 'place', 'place': _places[1]},
    {'type': 'story', 'story': _stories[0]},
    {'type': 'place', 'place': _places[2]},
    {'type': 'story', 'story': _stories[1]},
    {'type': 'place', 'place': _places[3]},
    {'type': 'story', 'story': _stories[2]},
  ];

  @override
  Future<Map<String, dynamic>> getProfile() async {
    await Future<void>.delayed(delay);
    return {
      'id': 'u_1',
      'full_name': 'Laila Hassan',
      'avatar': _avatar,
      'persona': 'newcomer',
      'city': 'Aswan, Egypt',
      'bio': 'Always looking for small stories and places locals love.',
      'stats': {
        'saved_places': 12,
        'saved_stories': 7,
        'posts': 4,
        'points': 160,
      },
      'saved_preview': [
        {'type': 'place', 'id': 'philae', 'image': AppImages.philaeTemple},
        {
          'type': 'place',
          'id': 'nubian-village',
          'image': AppImages.nubianVillage,
        },
        {
          'type': 'place',
          'id': 'elephantine',
          'image': AppImages.elephantineIsland,
        },
      ],
      'contributions': {
        'reports_under_review': 1,
        'added_activities': 2,
        'guide_requests_pending': 1,
      },
    };
  }

  @override
  Future<String> uploadAvatar(UploadFile photo) async {
    await Future<void>.delayed(delay);
    final problem = checkUpload(photo);
    if (problem != null) {
      throw AppException(
        code: ErrorCodes.validation,
        statusCode: 422,
        details: {'avatar': problem},
      );
    }
    // A real server returns a URL; the mock keeps the picked file's path.
    return _avatar = photo.path;
  }

  @override
  Future<Paged<Map<String, dynamic>>> getSaved({
    String? type,
    int page = 1,
  }) async {
    await Future<void>.delayed(delay);
    if (type != null && type != 'place' && type != 'story') {
      throw const AppException(
        code: ErrorCodes.validation,
        statusCode: 422,
        details: {'type': ErrorCodes.validation},
      );
    }
    final all = _saved.where((e) => type == null || e['type'] == type).toList();
    final pages = all.isEmpty ? 1 : (all.length / pageSize).ceil();
    return Paged(
      items: all.skip((page - 1) * pageSize).take(pageSize).toList(),
      page: page,
      totalPages: pages,
      total: all.length,
    );
  }

  @override
  Future<Map<String, dynamic>> getSettings() async {
    await Future<void>.delayed(delay);
    return {..._settings};
  }

  @override
  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> body) async {
    await Future<void>.delayed(delay);
    lastSettingsPatch = body;
    _settings = {..._settings, ...body};
    return {..._settings};
  }

  @override
  Future<void> requestDeletion() async {
    await Future<void>.delayed(delay);
    if (_deletionRequested) {
      throw const AppException(
        code: ErrorCodes.deletionAlreadyRequested,
        statusCode: 409,
      );
    }
    _deletionRequested = true;
  }
}
