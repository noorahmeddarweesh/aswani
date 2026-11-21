import '../../../../core/pagination/paged.dart';
import '../../../../core/result/guard.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/story.dart';
import '../../domain/repositories/culture_repository.dart';
import '../datasources/culture_datasource.dart';
import '../mappers/culture_mapper.dart';
import '../models/culture_dtos.dart';

class CultureRepositoryImpl implements CultureRepository {
  CultureRepositoryImpl(this._source);

  final CultureDataSource _source;

  @override
  Future<Result<CultureHome>> getHome() =>
      guard(() async => cultureHomeFromJson(await _source.getHome()));

  @override
  Future<Result<Paged<StorySummary>>> getStories({
    CultureTheme? theme,
    int page = 1,
  }) => guard(
    () async => (await _source.getStories(
      theme: theme?.wire,
      page: page,
    )).map((j) => StorySummaryDto(j).toEntity()),
  );

  @override
  Future<Result<Story>> getStory(String id) =>
      guard(() async => StorySummaryDto(await _source.getStory(id)).toStory());

  @override
  Future<Result<bool>> setSaved(String storyId, {required bool saved}) =>
      guard(() => _source.setSaved(storyId, saved: saved));

  @override
  Future<Result<Paged<StorySummary>>> getSaved({int page = 1}) => guard(
    () async =>
        (await _source.getSaved(page: page))
            .map((j) => StorySummaryDto(j).toEntity()),
  );
}
