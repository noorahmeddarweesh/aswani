import 'dart:async';
import 'dart:typed_data';

import 'package:aswani/core/assets/app_images.dart';
import 'package:aswani/core/network/upload.dart';
import 'package:aswani/core/router/app_router.dart';
import 'package:aswani/core/session/session_controller.dart';
import 'package:aswani/features/community/presentation/viewmodels/community_feed_view_model.dart';
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

void main() {
  testWidgets('feed: appreciate a post, filter by a highlight', (tester) async {
    final container = await _signedIn(tester);
    container.read(appRouterProvider).go('/community');
    await tester.pumpAndSettle();

    expect(find.text('124 appreciations'), findsOneWidget);
    await tester.tap(find.byTooltip('Appreciate').first);
    await tester.pumpAndSettle();
    expect(find.text('125 appreciations'), findsOneWidget);

    await tester.tap(find.text('Nubia'));
    await tester.pumpAndSettle();
    expect(
      container.read(communityFeedProvider).value!.posts.single.id,
      'p_mariam',
    );
    await tester.tap(find.text('Nubia'));
    await tester.pumpAndSettle();
    expect(container.read(communityFeedProvider).value!.posts, hasLength(4));
  });

  testWidgets('post details: comment, then the feed shows the new count', (
    tester,
  ) async {
    final container = await _signedIn(tester);
    final router = container.read(appRouterProvider)..go('/community');
    await tester.pumpAndSettle();
    unawaited(router.push('/community/posts/p_sunset'));
    await tester.pumpAndSettle();

    expect(find.text('Comments'), findsOneWidget);
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
