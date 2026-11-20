import 'dart:async';
import 'dart:typed_data';

import 'package:aswani/core/assets/app_images.dart';
import 'package:aswani/core/network/upload.dart';
import 'package:aswani/core/router/app_router.dart';
import 'package:aswani/core/session/session_controller.dart';
import 'package:aswani/features/community/presentation/viewmodels/community_feed_view_model.dart';
import 'package:aswani/features/community/presentation/widgets/post_widgets.dart';
import 'package:aswani/shared/widgets/photo_picker_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

Future<ProviderContainer> _signedIn(
  WidgetTester tester, {
  List<Override> overrides = const [],
}) async {
  final container = await pumpApp(tester, overrides: overrides);
  container
      .read(sessionProvider.notifier)
      .signedIn(
        const Session(
          userId: 'u_1',
          displayName: 'Laila Hassan',
          hasPreferences: true,
          avatarUrl: AppImages.avatarLaila,
        ),
      );
  await tester.pumpAndSettle();
  return container;
}

/// Moves time on in small steps (the story viewer never settles).
Future<void> _play(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 50) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets('feed: header, appreciate, double tap, likes and comments', (
    tester,
  ) async {
    final container = await _signedIn(tester);
    container.read(appRouterProvider).go('/community');
    await tester.pumpAndSettle();

    expect(find.text('Aswani community'), findsOneWidget);
    expect(find.text('FROM PEOPLE, FOR PEOPLE'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);

    expect(find.text('124 appreciations'), findsOneWidget);
    await tester.tap(find.byTooltip('Appreciate').first);
    await tester.pumpAndSettle();
    expect(find.text('125 appreciations'), findsOneWidget);

    // Double tap on the photo appreciates; a second one never takes it back.
    final photo = find.byType(PostImages).first;
    await tester.tap(find.byTooltip('Remove appreciation').first);
    await tester.pumpAndSettle();
    expect(find.text('124 appreciations'), findsOneWidget);
    for (var i = 0; i < 2; i++) {
      await tester.tap(photo);
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tap(photo);
      await tester.pumpAndSettle();
    }
    expect(find.text('125 appreciations'), findsOneWidget);

    // Who appreciated it.
    await tester.tap(find.text('125 appreciations'));
    await tester.pumpAndSettle();
    expect(find.text('Appreciations'), findsOneWidget);
    expect(find.text('Laila Hassan'), findsWidgets);
    expect(find.text('Mariam Ahmed'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    // Comments open over the feed; an emoji and a comment go in.
    await tester.tap(find.byTooltip('Comment').first);
    await tester.pumpAndSettle();
    expect(find.text('Comments'), findsOneWidget);
    expect(find.text('Adding this walk to my list!'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'So beautiful ');
    await tester.tap(find.text('🔥'));
    await tester.pump();
    await tester.tap(find.byTooltip('Send comment'));
    await tester.pumpAndSettle();
    expect(find.text('So beautiful 🔥'), findsOneWidget);
    final feedPost = container
        .read(communityFeedProvider)
        .value!
        .posts
        .firstWhere((p) => p.id == 'p_sunset');
    expect(feedPost.commentCount, 4);
  });

  testWidgets('a story circle opens its moments full screen', (tester) async {
    final container = await _signedIn(tester);
    final router = container.read(appRouterProvider)..go('/community');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nubian colors'));
    // The viewer keeps playing, so pump by time, never "settle".
    await _play(tester, 400);
    expect(router.state.matchedLocation, '/community/highlights/h_nubia');
    // Most appreciated first: Mariam (87), then the museum (74).
    expect(
      find.textContaining('Mariam Ahmed', findRichText: true),
      findsOneWidget,
    );

    await _play(tester, 5100);
    expect(
      find.textContaining('Youssef El Nuby', findRichText: true),
      findsOneWidget,
    );

    // Tap the start side to go back.
    await tester.tapAt(const Offset(20, 400));
    await _play(tester, 100);
    expect(
      find.textContaining('Mariam Ahmed', findRichText: true),
      findsOneWidget,
    );

    // Appreciate from the story: the feed has the same number.
    await tester.tap(find.byTooltip('Remove appreciation'));
    await _play(tester, 100);
    expect(find.text('86'), findsOneWidget);
    expect(
      container
          .read(communityFeedProvider)
          .value!
          .posts
          .firstWhere((p) => p.id == 'p_mariam')
          .likeCount,
      86,
    );

    await tester.tap(find.text('View post'));
    await _play(tester, 500);
    expect(router.state.matchedLocation, '/community/posts/p_mariam');
    router.pop();
    await _play(tester, 500);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(router.state.matchedLocation, '/community');
  });

  testWidgets('drag a story down to close it', (tester) async {
    final container = await _signedIn(tester);
    final router = container.read(appRouterProvider)..go('/community');
    await tester.pumpAndSettle();
    await tester.tap(find.text('On the Nile'));
    await _play(tester, 400);
    await tester.drag(find.byType(PageView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(router.state.matchedLocation, '/community');
  });

  testWidgets('Your moment: camera first, then New post with the photo', (
    tester,
  ) async {
    final container = await _signedIn(
      tester,
      overrides: [
        takePhotoProvider.overrideWithValue(
          () async => UploadFile(
            name: 'cam.jpg',
            bytes: _png,
            path: AppImages.homeHero,
          ),
        ),
      ],
    );
    final router = container.read(appRouterProvider)..go('/community');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Your moment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take a photo'));
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), '/community/new?source=camera');
    await tester.enterText(find.byType(TextField), 'Right now');
    await tester.pump();
    final publish = find.widgetWithText(FilledButton, 'Publish to community');
    expect(tester.widget<FilledButton>(publish).onPressed, isNotNull);
  });

  testWidgets('post details: comment box under the post', (tester) async {
    final container = await _signedIn(tester);
    final router = container.read(appRouterProvider)..go('/community');
    await tester.pumpAndSettle();
    unawaited(router.push('/community/posts/p_sunset'));
    await tester.pumpAndSettle();

    expect(find.text('From the community'), findsOneWidget);
    expect(find.text('Adding this walk to my list!'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'So beautiful');
    await tester.pump();
    await tester.tap(find.byTooltip('Send comment'));
    await tester.pumpAndSettle();
    expect(find.text('So beautiful'), findsOneWidget);
    final feedPost = container
        .read(communityFeedProvider)
        .value!
        .posts
        .firstWhere((p) => p.id == 'p_sunset');
    expect(feedPost.commentCount, 4);
  });

  testWidgets('new post: publish with a photo and a caption', (tester) async {
    final container = await _signedIn(
      tester,
      overrides: [
        pickPhotosProvider.overrideWithValue(
          (max) async => [
            UploadFile(name: 'x.jpg', bytes: _png, path: AppImages.homeHero),
          ],
        ),
      ],
    );
    final router = container.read(appRouterProvider)..go('/community');
    await tester.pumpAndSettle();
    unawaited(router.push('/community/new'));
    await tester.pumpAndSettle();

    final publish = find.widgetWithText(FilledButton, 'Publish to community');
    expect(tester.widget<FilledButton>(publish).onPressed, isNull);

    await tester.tap(find.text('Choose photos'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Felucca at noon');
    await tester.pump();
    expect(tester.widget<FilledButton>(publish).onPressed, isNotNull);

    await tester.tap(publish);
    await tester.pumpAndSettle();
    expect(router.state.matchedLocation, '/community');
    expect(find.text('Your post is live.'), findsOneWidget);
    expect(
      container.read(communityFeedProvider).value!.posts.first.caption,
      'Felucca at noon',
    );
  });
}

// 1x1 transparent PNG.
final _png = Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);
