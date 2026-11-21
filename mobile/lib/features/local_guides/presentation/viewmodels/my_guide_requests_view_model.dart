import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../domain/entities/guide_request.dart';
import '../../local_guides_providers.dart';

/// "Guide requests" (from Profile): the user's requests, newest first,
/// as the API returns them (GET /guide-requests/mine).
final myGuideRequestsProvider =
    FutureProvider.autoDispose<List<GuideRequestItem>>((ref) async {
      final result = await ref
          .read(localGuidesRepositoryProvider)
          .getGuideRequestsMine(limit: 50);
      return switch (result) {
        Success(:final value) => value.data,
        Error(:final failure) => throw failure,
      };
      // The page has its own "Try again" button, so a failure shows at once
      // instead of a skeleton while Riverpod retries in the background.
    }, retry: (_, _) => null);
