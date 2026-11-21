import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/pagination/paged.dart';
import '../../../../core/result/result.dart';
import '../../culture_providers.dart';
import '../../domain/entities/story.dart';

T _value<T>(Result<T> result) => switch (result) {
  Success(:final value) => value,
  Error(:final failure) => throw failure,
};

/// Culture home: featured story, themes and selected reads (one call).
final cultureHomeProvider = FutureProvider.autoDispose<CultureHome>(
  (ref) async => _value(await ref.read(cultureRepositoryProvider).getHome()),
);

/// One story with its blocks.
final storyProvider = FutureProvider.autoDispose.family<Story, String>(
  (ref, id) async =>
      _value(await ref.read(cultureRepositoryProvider).getStory(id)),
);

/// Stories of one theme (null = all), with paging.
class StoriesListViewModel extends AsyncNotifier<Paged<StorySummary>> {
  StoriesListViewModel(this.theme);

  final CultureTheme? theme;

  @override
  Future<Paged<StorySummary>> build() async => _value(
    await ref.read(cultureRepositoryProvider).getStories(theme: theme),
  );

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore) return;
    final result = await ref
        .read(cultureRepositoryProvider)
        .getStories(theme: theme, page: current.page + 1);
    if (!ref.mounted) return;
    if (result case Success(:final value)) {
      state = AsyncData(
        Paged(
          items: [...current.items, ...value.items],
          page: value.page,
          totalPages: value.totalPages,
          total: value.total,
        ),
      );
    }
  }
}

final storiesListProvider = AsyncNotifierProvider.autoDispose
    .family<StoriesListViewModel, Paged<StorySummary>, CultureTheme?>(
      StoriesListViewModel.new,
    );

/// Saved reads.
final savedStoriesProvider = FutureProvider.autoDispose<Paged<StorySummary>>(
  (ref) async => _value(await ref.read(cultureRepositoryProvider).getSaved()),
);

/// Saved / not saved changes made in this session, by story id. Every
/// screen reads `isSaved(story)`, so a story saved on its page shows as
/// saved on Culture home and in lists too, without reloading them.
class StorySaves extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() => const {};

  bool isSaved(StorySummary story) => state[story.id] ?? story.isSaved;

  /// Changes at once; rolls back and returns the error code if it fails.
  Future<String?> toggle(StorySummary story) async {
    final saved = !isSaved(story);
    state = {...state, story.id: saved};
    final result = await ref
        .read(cultureRepositoryProvider)
        .setSaved(story.id, saved: saved);
    switch (result) {
      case Success():
        ref.invalidate(savedStoriesProvider);
        return null;
      case Error(:final failure):
        state = {...state, story.id: !saved};
        return failure.code;
    }
  }
}

final storySavesProvider = NotifierProvider<StorySaves, Map<String, bool>>(
  StorySaves.new,
);
