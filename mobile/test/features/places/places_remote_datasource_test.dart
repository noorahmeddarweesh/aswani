import 'package:aswani/features/personalization/data/datasources/preferences_remote_datasource.dart';
import 'package:aswani/features/personalization/data/models/preferences_dto.dart';
import 'package:aswani/features/places/data/datasources/places_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_api.dart';

const _place = {
  'id': 'philae',
  'category': 'history',
  'name_en': 'Philae Temple',
  'name_ar': 'معبد فيلة',
  'label_en': 'Heritage & history',
  'label_ar': 'تراث وتاريخ',
  'tagline_en': 'History on an island',
  'tagline_ar': 'تاريخ على جزيرة',
  'city_en': 'Aswan',
  'city_ar': 'أسوان',
  'image': 'https://api.test/images/places/philae.jpg',
  'is_curated': true,
  'is_editors_pick': true,
  'is_bookmarked': false,
};

void main() {
  late FakeApi api;
  late PlacesRemoteDataSource remote;

  setUp(() {
    api = FakeApi(
      (_) => reply(200, {
        'data': [_place],
        'meta': {'page': 1, 'limit': 50, 'total': 1, 'total_pages': 1},
      }),
    );
    remote = PlacesRemoteDataSource(api.client());
  });

  test('places list sends category and paging, reads data', () async {
    final places = await remote.getPlaces(category: 'history');
    final request = api.requests.single;
    expect(request.path, '/places');
    expect(request.queryParameters, {
      'category': 'history',
      'page': 1,
      'limit': 50,
    });
    expect(places.single.nameAr, 'معبد فيلة');

    await remote.getPlaces();
    expect(api.requests.last.queryParameters.containsKey('category'), isFalse);
  });

  test('curated places come from /places/curated', () async {
    await remote.getCurated();
    expect(api.requests.single.path, '/places/curated');
  });

  test('bookmark: POST to save, DELETE to remove', () async {
    api.handler = (_) => reply(201, {
      'data': {..._place, 'is_bookmarked': true},
    });
    final saved = await remote.setBookmark('philae', saved: true);
    expect(api.requests.last.method, 'POST');
    expect(api.requests.last.path, '/bookmarks');
    expect(api.requests.last.data, {'place_id': 'philae'});
    expect(saved.isBookmarked, isTrue);

    api.handler = (_) => reply(200, {'data': _place});
    final removed = await remote.setBookmark('philae', saved: false);
    expect(api.requests.last.method, 'DELETE');
    expect(api.requests.last.path, '/bookmarks/philae');
    expect(removed.isBookmarked, isFalse);
  });

  test('preferences are saved with PUT /users/preferences', () async {
    api.handler = (_) => reply(204);
    const dto = PreferencesDto(
      persona: 'visitor',
      purpose: null,
      stayLength: 'few_days',
      interests: ['nubian'],
      travelStyles: [],
      companions: null,
      needs: ['finding_places'],
      language: 'ar',
    );
    await PreferencesRemoteDataSource(api.client()).save(dto);
    expect(api.requests.last.method, 'PUT');
    expect(api.requests.last.path, '/users/preferences');
    expect(api.requests.last.data, dto.toJson());
  });
}
