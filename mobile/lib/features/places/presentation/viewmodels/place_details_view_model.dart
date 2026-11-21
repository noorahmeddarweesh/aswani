import 'package:aswani/core/result/result.dart';
import 'package:aswani/features/places/domain/entities/place_details.dart';
import 'package:aswani/features/places/place_details_providers.dart';
import 'package:aswani/features/places/places_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages state for the Place Details Screen: loading, 404 error, retry, and bookmarking.
class PlaceDetailsViewModel extends AsyncNotifier<PlaceDetails> {
  PlaceDetailsViewModel(this.placeId);

  final String placeId;

  @override
  Future<PlaceDetails> build() async {
    return _load(placeId);
  }

  Future<PlaceDetails> _load(String id) async {
    final repository = ref.watch(placeDetailsRepositoryProvider);
    final result = await repository.getPlaceDetails(id);
    return switch (result) {
      Success(:final value) => value,
      Error(:final failure) => throw failure,
    };
  }

  /// Retries fetching place details after an error.
  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(placeId));
  }

  /// Toggles the bookmark status of the place using Sprint 1 PlacesRepository.setBookmark().
  ///
  /// - Reads the current bookmark state.
  /// - Calls setBookmark(placeId, saved: !currentSaved).
  /// - Updates UI only after success.
  /// - Preserves previous state on failure.
  Future<bool> toggleBookmark() async {
    final current = state.value;
    if (current == null) return false;

    final nextSaved = !current.isBookmarked;
    final result = await ref
        .read(placesRepositoryProvider)
        .setBookmark(current.id, saved: nextSaved);

    if (!ref.mounted) return false;

    return switch (result) {
      Success(:final value) => () {
        state = AsyncValue.data(
          PlaceDetails(
            place: value,
            locationEn: current.locationEn,
            locationAr: current.locationAr,
            aboutEn: current.aboutEn,
            aboutAr: current.aboutAr,
            images: current.images,
            facts: current.facts,
          ),
        );
        return true;
      }(),
      Error() => false, // Preserve previous state on failure
    };
  }
}

final placeDetailsViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<PlaceDetailsViewModel, PlaceDetails, String>(
      PlaceDetailsViewModel.new,
    );
