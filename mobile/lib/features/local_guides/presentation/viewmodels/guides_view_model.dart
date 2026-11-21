import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../domain/entities/guide_enums.dart';
import '../../local_guides_providers.dart';
import 'guides_filter_state.dart';

/// Manages the filter state (selected specialty and debounced search query).
class GuidesFilterViewModel extends Notifier<GuidesFilter> {
  Timer? _debounceTimer;

  @override
  GuidesFilter build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return const GuidesFilter();
  }

  /// Toggles a specialty chip. Tapping an already-selected chip clears the filter.
  void toggleSpecialty(GuideSpecialty specialty) {
    if (state.specialty == specialty) {
      state = state.copyWith(clearSpecialty: true);
    } else {
      state = state.copyWith(specialty: specialty);
    }
  }

  /// Debounced search update (300 ms).
  void onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      state = state.copyWith(query: query.trim());
    });
  }

  /// Direct search update (used in tests or explicit search submissions).
  void searchImmediate(String query) {
    _debounceTimer?.cancel();
    state = state.copyWith(query: query.trim());
  }

  void clearFilter() {
    _debounceTimer?.cancel();
    state = const GuidesFilter(specialty: null, query: '');
  }
}

final guidesFilterProvider =
    NotifierProvider.autoDispose<GuidesFilterViewModel, GuidesFilter>(
      GuidesFilterViewModel.new,
    );

/// Loads and paginates guides according to the active filter.
class GuidesListViewModel extends AsyncNotifier<GuidesListState> {
  @override
  Future<GuidesListState> build() async {
    final filter = ref.watch(guidesFilterProvider);
    return _fetchPage(
      specialty: filter.specialty,
      query: filter.query,
      page: 1,
    );
  }

  Future<GuidesListState> _fetchPage({
    GuideSpecialty? specialty,
    String? query,
    int page = 1,
    int limit = 20,
  }) async {
    final repository = ref.read(localGuidesRepositoryProvider);
    final result = await repository.getGuides(
      specialty: specialty,
      query: (query != null && query.isNotEmpty) ? query : null,
      page: page,
      limit: limit,
    );

    return switch (result) {
      Success(:final value) => GuidesListState(
        guides: value.data,
        meta: value.meta,
      ),
      Error(:final failure) => throw failure,
    };
  }

  /// Pull-to-refresh or retry on error.
  Future<void> retry() async {
    if (state.hasError) state = const AsyncLoading();
    final filter = ref.read(guidesFilterProvider);
    final next = await AsyncValue.guard(
      () =>
          _fetchPage(specialty: filter.specialty, query: filter.query, page: 1),
    );
    if (ref.mounted) state = next;
  }

  /// Load more items for infinite scroll pagination.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));
    final filter = ref.read(guidesFilterProvider);
    final repository = ref.read(localGuidesRepositoryProvider);

    final result = await repository.getGuides(
      specialty: filter.specialty,
      query: filter.query.isNotEmpty ? filter.query : null,
      page: current.meta.page + 1,
      limit: current.meta.limit,
    );

    if (!ref.mounted) return;

    if (result case Success(:final value)) {
      final existingIds = current.guides.map((g) => g.id).toSet();
      final newItems = value.data
          .where((g) => !existingIds.contains(g.id))
          .toList();
      state = AsyncValue.data(
        current.copyWith(
          guides: [...current.guides, ...newItems],
          meta: value.meta,
          isLoadingMore: false,
        ),
      );
    } else {
      state = AsyncValue.data(current.copyWith(isLoadingMore: false));
    }
  }
}

final guidesListProvider =
    AsyncNotifierProvider.autoDispose<GuidesListViewModel, GuidesListState>(
      GuidesListViewModel.new,
    );
