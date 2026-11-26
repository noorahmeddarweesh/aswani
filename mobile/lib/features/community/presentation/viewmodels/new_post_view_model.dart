import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/upload.dart';
import '../../../../core/result/result.dart';
import '../../community_providers.dart';
import '../../domain/entities/post.dart';
import 'community_feed_view_model.dart';
import 'my_posts_view_model.dart';

class NewPostState {
  const NewPostState({
    this.photos = const [],
    this.caption = '',
    this.location = '',
    this.category = PostCategory.localExperience,
    this.submitting = false,
    this.failure,
  });

  final List<UploadFile> photos;
  final String caption;
  final String location;
  final PostCategory category;
  final bool submitting;
  final Failure? failure;

  /// "Publish" is enabled with at least one photo and a caption.
  bool get canPublish =>
      photos.isNotEmpty && caption.trim().isNotEmpty && !submitting;

  NewPostState copyWith({
    List<UploadFile>? photos,
    String? caption,
    String? location,
    PostCategory? category,
    bool? submitting,
    Failure? Function()? failure,
  }) => NewPostState(
    photos: photos ?? this.photos,
    caption: caption ?? this.caption,
    location: location ?? this.location,
    category: category ?? this.category,
    submitting: submitting ?? this.submitting,
    failure: failure != null ? failure() : this.failure,
  );
}

class NewPostViewModel extends Notifier<NewPostState> {
  /// Max caption length (contract v0.2).
  static const int maxCaption = 2000;

  @override
  NewPostState build() => const NewPostState();

  void setPhotos(List<UploadFile> photos) =>
      state = state.copyWith(photos: photos, failure: () => null);

  void setCaption(String value) => state = state.copyWith(caption: value);

  void setLocation(String value) =>
      state = state.copyWith(location: value.trim());

  void setCategory(PostCategory value) =>
      state = state.copyWith(category: value);

  /// Returns the new post, or null (the failure is in the state).
  Future<Post?> publish() async {
    if (!state.canPublish) return null;
    state = state.copyWith(submitting: true, failure: () => null);
    final result = await ref
        .read(communityRepositoryProvider)
        .createPost(
          caption: state.caption.trim(),
          category: state.category,
          images: state.photos,
          location: state.location.isEmpty ? null : state.location,
        );
    if (!ref.mounted) return null;
    switch (result) {
      case Success(:final value):
        if (ref.read(communityFeedProvider.exists)) {
          ref.read(communityFeedProvider.notifier).insertFirst(value);
        }
        if (ref.read(myPostsProvider.exists)) {
          ref.read(myPostsProvider.notifier).insertFirst(value);
        }
        state = state.copyWith(submitting: false);
        return value;
      case Error(:final failure):
        state = state.copyWith(submitting: false, failure: () => failure);
        return null;
    }
  }
}

final newPostProvider =
    NotifierProvider.autoDispose<NewPostViewModel, NewPostState>(
      NewPostViewModel.new,
    );
