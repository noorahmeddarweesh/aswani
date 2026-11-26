import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../../places/domain/entities/place.dart';
import '../../../places/places_providers.dart';

/// Home loads the curated places; the rest of Home is static content for now.
class HomeViewModel extends AsyncNotifier<List<Place>> {
  @override
  Future<List<Place>> build() async {
    final result = await ref.read(placesRepositoryProvider).getCurated();
    return switch (result) {
      Success(:final value) => value,
      Error(:final failure) => throw failure,
    };
  }

  Future<void> toggleBookmark(String placeId) async {
    final place = state.value?.where((p) => p.id == placeId).firstOrNull;
    if (place == null) return;
    final result = await ref
        .read(placesRepositoryProvider)
        .setBookmark(placeId, saved: !place.isBookmarked);
    if (!ref.mounted) return;
    if (result case Success(:final value)) {
      final list = state.value ?? const <Place>[];
      state = AsyncValue.data([
        for (final p in list) p.id == value.id ? value : p,
      ]);
    }
  }
}

final homeViewModelProvider =
    AsyncNotifierProvider.autoDispose<HomeViewModel, List<Place>>(
      HomeViewModel.new,
    );

enum DayPart { morning, afternoon, evening }

DayPart dayPartOf(DateTime time) => time.hour < 12
    ? DayPart.morning
    : time.hour < 17
    ? DayPart.afternoon
    : DayPart.evening;
