import '../../../../core/assets/app_images.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/upload.dart';
import '../../../../core/pagination/paged.dart';
import 'contributions_datasource.dart';

/// Keeps contributions in memory; each one starts `pending` like the API.
class ContributionsMockDataSource implements ContributionsDataSource {
  ContributionsMockDataSource({
    this.delay = const Duration(milliseconds: 600),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final Duration delay;
  final DateTime Function() _now;
  int _nextId = 2;

  late final List<Map<String, dynamic>> _mine = [
    {
      'id': 'k_1',
      'category': 'cafe',
      'name': 'Nile View Café',
      'description': 'Hibiscus tea and a quiet terrace on the river.',
      'address': 'Corniche El Nil, near the ferry',
      'contact_number': '01012345678',
      'photos': [AppImages.homeHero2],
      'status': 'accepted',
      'points_awarded': 25,
      'created_at': _now()
          .toUtc()
          .subtract(const Duration(days: 12))
          .toIso8601String(),
    },
  ];

  void _check(Map<String, Object?> fields, int photoCount) {
    if (photoCount > UploadRules.maxPhotos) {
      throw const AppException(code: ErrorCodes.tooManyPhotos, statusCode: 422);
    }
    final missing = [
      for (final f in ['category', 'name', 'description', 'address'])
        if ('${fields[f] ?? ''}'.trim().isEmpty) f,
    ];
    if (missing.isNotEmpty) {
      throw AppException(
        code: ErrorCodes.validation,
        statusCode: 422,
        details: {for (final f in missing) f: ErrorCodes.validation},
      );
    }
  }

  Map<String, dynamic> _find(String id) => _mine.firstWhere(
    (c) => c['id'] == id,
    orElse: () => throw const AppException(
      code: ErrorCodes.contributionNotFound,
      statusCode: 404,
    ),
  );

  @override
  Future<Map<String, dynamic>> submit(
    Map<String, Object?> fields,
    List<UploadFile> photos,
  ) async {
    await Future<void>.delayed(delay);
    _check(fields, photos.length);
    final id = 'k_${_nextId++}';
    _mine.insert(0, {
      'id': id,
      'category': fields['category'],
      'name': fields['name'],
      'description': fields['description'],
      'address': fields['address'],
      'contact_number': fields['contact_number'],
      'photos': [for (final p in photos) p.path],
      'status': 'pending',
      'points_awarded': 0,
      'created_at': _now().toUtc().toIso8601String(),
    });
    return {'id': id, 'status': 'pending'};
  }

  @override
  Future<Map<String, dynamic>> getOne(String id) async {
    await Future<void>.delayed(delay);
    return {..._find(id)};
  }

  @override
  Future<Map<String, dynamic>> update(
    String id,
    Map<String, Object?> fields,
    List<UploadFile> photos,
  ) async {
    await Future<void>.delayed(delay);
    final current = _find(id);
    final keep = switch (fields['keep_photos']) {
      final List<Object?> l => l.cast<String>(),
      _ => const <String>[],
    };
    _check(fields, keep.length + photos.length);
    current
      ..addAll({
        for (final f in ['category', 'name', 'description', 'address'])
          f: fields[f],
        'contact_number': fields['contact_number'],
        'photos': [...keep, for (final p in photos) p.path],
      })
      // Reviewed again; points already awarded stay.
      ..['status'] = 'pending';
    return {...current};
  }

  @override
  Future<Paged<Map<String, dynamic>>> getMine({int page = 1}) async {
    await Future<void>.delayed(delay);
    return Paged(
      items: page == 1 ? List.of(_mine) : const [],
      page: page,
      totalPages: 1,
      total: _mine.length,
    );
  }
}
