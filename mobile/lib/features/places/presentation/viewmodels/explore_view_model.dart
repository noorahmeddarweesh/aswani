import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/place.dart';
import '../../places_providers.dart';

/// What the user picked on Explore: a category (null = "All") and search text.
class ExploreFilter {
  const ExploreFilter({this.category, this.query = ''});

  final PlaceCategory? category;
  final String query;
}

class ExploreViewModel extends Notifier<ExploreFilter> {
  @override
  ExploreFilter build() => const ExploreFilter();

  void selectCategory(PlaceCategory? category) =>
      state = ExploreFilter(category: category, query: state.query);

  void search(String query) =>
      state = ExploreFilter(category: state.category, query: query);
}

final exploreViewModelProvider =
    NotifierProvider.autoDispose<ExploreViewModel, ExploreFilter>(
      ExploreViewModel.new,
    );

/// Places of the selected category. Reloads when the category changes.
///
/// Kept apart from [ExploreViewModel] on purpose: this list depends on the
/// filter, so the filter must not refresh the list itself (Riverpod reports
/// that as a circular dependency).
class ExplorePlaces extends AsyncNotifier<List<Place>> {
  @override
  Future<List<Place>> build() {
    final category = ref.watch(
      exploreViewModelProvider.select((f) => f.category),
    );
    return _load(category);
  }

  Future<List<Place>> _load(PlaceCategory? category) async {
    final result = await ref
        .read(placesRepositoryProvider)
        .getPlaces(category: category);
    return switch (result) {
      Success(:final value) => value,
      Error(:final failure) => throw failure,
    };
  }

  /// Pull-to-refresh and the error view's "Try again".
  Future<void> retry() async {
    if (state.hasError) state = const AsyncLoading();
    final category = ref.read(exploreViewModelProvider).category;
    final next = await AsyncValue.guard(() => _load(category));
    if (ref.mounted) state = next;
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

final explorePlacesProvider =
    AsyncNotifierProvider.autoDispose<ExplorePlaces, List<Place>>(
      ExplorePlaces.new,
    );

/// Applies the search text locally (the API search comes later).
List<Place> applySearch(List<Place> places, String query, String lang) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return places;
  return places
      .where(
        (p) =>
            p.nameEn.toLowerCase().contains(q) ||
            p.nameAr.contains(q) ||
            p.label(lang).toLowerCase().contains(q),
      )
      .toList();
}

/// Error code of a failed load.
String errorCodeOf(Object error) =>
    error is Failure ? error.code : ErrorCodes.unknown;
