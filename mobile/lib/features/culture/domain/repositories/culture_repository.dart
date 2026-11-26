import '../../../../core/pagination/paged.dart';
import '../../../../core/result/result.dart';
import '../entities/story.dart';

abstract interface class CultureRepository {
  Future<Result<CultureHome>> getHome();

  Future<Result<Paged<StorySummary>>> getStories({
    CultureTheme? theme,
    int page = 1,
  });

  Future<Result<Story>> getStory(String id);

  /// Returns the new saved state.
  Future<Result<bool>> setSaved(String storyId, {required bool saved});

  Future<Result<Paged<StorySummary>>> getSaved({int page = 1});
}
