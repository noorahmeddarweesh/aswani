import 'dart:async';

import 'package:aswani/core/result/result.dart';
import 'package:aswani/core/router/app_router.dart';
import 'package:aswani/core/session/session_controller.dart';
import 'package:aswani/features/culture/data/datasources/culture_mock_datasource.dart';
import 'package:aswani/features/culture/data/datasources/culture_remote_datasource.dart';
import 'package:aswani/features/culture/data/repositories/culture_repository_impl.dart';
import 'package:aswani/features/culture/domain/entities/story.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_api.dart';
import '../../helpers/pump_app.dart';

T ok<T>(Result<T> r) => (r as Success<T>).value;

void main() {
  group('repository (mock)', () {
    final repo = CultureRepositoryImpl(
      CultureMockDataSource(delay: Duration.zero),
    );

    test('home: featured, four themes, selected reads', () async {
      final home = ok(await repo.getHome());
      expect(home.featured.id, 's_homes');
      expect(home.themes.map((t) => t.theme), CultureTheme.values);
      expect(home.selectedReads, hasLength(3));
    });

    test('a story has blocks in both languages', () async {
      final story = ok(await repo.getStory('s_homes'));
      expect(story.blocks.first.type, StoryBlockType.lead);
      expect(story.blocks.first.text('ar'), startsWith('في القرى النوبية'));
      expect(story.summary.location('ar'), 'غرب سهيل');
      final missing = await repo.getStory('nope');
      expect((missing as Error).failure.code, 'STORY_NOT_FOUND');
    });

    test('theme filter and saved reads', () async {
      final traditions = ok(
        await repo.getStories(theme: CultureTheme.traditions),
      );
      expect(traditions.items.map((s) => s.id), ['s_nile', 's_souq']);
      expect(ok(await repo.setSaved('s_nile', saved: true)), isTrue);
      expect(ok(await repo.getSaved()).items.single.id, 's_nile');
    });
  });

  test('remote: paths and parsing match contract v0.2', () async {
    final story = {
      'id': 's1',
      'theme': 'traditions',
      'title_en': 'T',
      'title_ar': 'ت',
      'cover_image': 'https://api.test/s1.jpg',
      'read_minutes': 3,
      'blocks': [
        {'type': 'quote', 'text_en': 'Q', 'text_ar': 'ق'},
      ],
    };
    final api = FakeApi(
      (r) => switch ((r.method, r.path)) {
        ('GET', '/culture/home') => reply(200, {
          'data': {
            'featured': story,
            'themes': [
              {
                'id': 'traditions',
                'title_en': 'T',
                'title_ar': 'ت',
                'image': 'x',
              },
              {
                'id': 'unknown_theme',
                'title_en': '?',
                'title_ar': '?',
                'image': 'x',
              },
            ],
            'selected_reads': [story],
          },
        }),
        ('GET', '/culture/stories/s1') => reply(200, {'data': story}),
        (_, '/culture/stories/s1/save') => reply(200, {
          'data': {'is_saved': r.method == 'POST'},
        }),
        _ => reply(200, {
          'data': [story],
          'meta': {'page': 1, 'limit': 20, 'total': 1, 'total_pages': 1},
        }),
      },
    );
    final repo = CultureRepositoryImpl(CultureRemoteDataSource(api.client()));

    final home = ok(await repo.getHome());
    expect(home.themes, hasLength(1), reason: 'unknown themes are skipped');
    expect(ok(await repo.getStory('s1')).blocks.single.text('ar'), 'ق');
    expect(ok(await repo.setSaved('s1', saved: true)), isTrue);
    expect(ok(await repo.setSaved('s1', saved: false)), isFalse);
    expect(api.requests.last.method, 'DELETE');
    await repo.getStories(theme: CultureTheme.artsCrafts, page: 2);
    expect(api.requests.last.queryParameters, {
      'theme': 'arts_crafts',
      'page': 2,
      'limit': 20,
    });
  });

  testWidgets('saving a story shows it as saved everywhere', (tester) async {
    final container = await pumpApp(tester);
    container
        .read(sessionProvider.notifier)
        .signedIn(
          const Session(userId: 'u_1', displayName: 'L', hasPreferences: true),
        );
    await tester.pumpAndSettle();
    final router = container.read(appRouterProvider)..go('/culture');
    await tester.pumpAndSettle();
    expect(find.text('Homes that speak in color'), findsOneWidget);

    await tester.tap(find.text('Homes that speak in color'));
    await tester.pumpAndSettle();
    expect(find.text('Read the place slowly'), findsNothing); // below the fold
    await tester.tap(find.byTooltip('Save story'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Remove from saved'), findsOneWidget);

    unawaited(router.push('/culture/saved'));
    await tester.pumpAndSettle();
    expect(find.text('Homes that speak in color'), findsOneWidget);
  });
}
