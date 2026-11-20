import '../../../../core/pagination/paged.dart';

/// Culture endpoints of contract v0.2. Returns the JSON `data` objects; the
/// repository maps them.
abstract interface class CultureDataSource {
  /// GET /api/culture/home -> `{ featured, themes, selected_reads }`
  Future<Map<String, dynamic>> getHome();

  /// GET /api/culture/stories?theme=&page=&limit=
  Future<Paged<Map<String, dynamic>>> getStories({String? theme, int page = 1});

  /// GET /api/culture/stories/{id}
  Future<Map<String, dynamic>> getStory(String id);

  /// POST (save) or DELETE (unsave) /api/culture/stories/{id}/save
  Future<bool> setSaved(String storyId, {required bool saved});

  /// GET /api/culture/saved?page=&limit=
  Future<Paged<Map<String, dynamic>>> getSaved({int page = 1});
}
