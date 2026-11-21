import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../domain/entities/guide.dart';
import '../../local_guides_providers.dart';

/// Provides guide details for a given guide [id].
/// Uses autoDispose so cached data is cleared when leaving the details screen.
final guideDetailsProvider =
    FutureProvider.autoDispose.family<Guide, String>((ref, id) async {
  final repository = ref.watch(localGuidesRepositoryProvider);
  final result = await repository.getGuide(id);

  return switch (result) {
    Success(:final value) => value,
    Error(:final failure) => throw failure,
  };
});
