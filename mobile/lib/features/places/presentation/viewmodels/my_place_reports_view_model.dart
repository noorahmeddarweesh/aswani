import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../domain/entities/place_report.dart';
import '../../place_details_providers.dart';

/// "My place reports" (from Profile): the user's reports, newest first,
/// as the API returns them (GET /place-reports/mine).
final myPlaceReportsProvider =
    FutureProvider.autoDispose<List<PlaceReportItem>>((ref) async {
      final result = await ref
          .read(placeDetailsRepositoryProvider)
          .getPlaceReportsMine(limit: 50);
      return switch (result) {
        Success(:final value) => value.data,
        Error(:final failure) => throw failure,
      };
      // The page has its own "Try again" button, so a failure shows at once
      // instead of a skeleton while Riverpod retries in the background.
    }, retry: (_, _) => null);
