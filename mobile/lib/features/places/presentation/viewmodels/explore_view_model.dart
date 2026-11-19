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

  Future<void> retry() => ref.refresh(explorePlacesProvider.future);

  Future<void> toggleBookmark(String placeId) async {
    final result = await ref
        .read(placesRepositoryProvider)
        .toggleBookmark(placeId);
    if (!ref.mounted) return;
    if (result is Success<Place>) ref.invalidate(explorePlacesProvider);
  }
}

final exploreViewModelProvider =
    NotifierProvider.autoDispose<ExploreViewModel, ExploreFilter>(
      ExploreViewModel.new,
    );

/// Places of the selected category. Reloads when the category changes.
final explorePlacesProvider = FutureProvider.autoDispose<List<Place>>((
  ref,
) async {
  final category = ref.watch(
    exploreViewModelProvider.select((f) => f.category),
  );
  final result = await ref
      .read(placesRepositoryProvider)
      .getPlaces(category: category);
  return switch (result) {
    Success(:final value) => value,
    Error(:final failure) => throw failure,
  };
});

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
