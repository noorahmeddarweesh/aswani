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
      'status': 'accepted',
      'points_awarded': 25,
      'created_at': _now()
          .toUtc()
          .subtract(const Duration(days: 12))
          .toIso8601String(),
    },
  ];

  @override
  Future<Map<String, dynamic>> submit(
    Map<String, Object?> fields,
    List<UploadFile> photos,
  ) async {
    await Future<void>.delayed(delay);
    if (photos.length > UploadRules.maxPhotos) {
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
    final id = 'k_${_nextId++}';
    _mine.insert(0, {
      'id': id,
      'category': fields['category'],
      'name': fields['name'],
      'status': 'pending',
      'points_awarded': 0,
      'created_at': _now().toUtc().toIso8601String(),
    });
    return {'id': id, 'status': 'pending'};
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
