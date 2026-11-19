import 'package:aswani/core/theme/app_motion.dart';
import 'package:aswani/core/theme/app_theme.dart';
import 'package:aswani/shared/widgets/auto_carousel.dart';
import 'package:aswani/shared/widgets/motion.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('FadeSlideIn ends fully visible in its place', (tester) async {
    await tester.pumpWidget(
      _host(const FadeSlideIn(index: 2, child: Text('hello'))),
    );
    final opacity = find.ancestor(
      of: find.text('hello'),
      matching: find.byType(Opacity),
    );
    expect(tester.widget<Opacity>(opacity).opacity, 0);

    await tester.pumpAndSettle();
    expect(tester.widget<Opacity>(opacity).opacity, 1);
  });

  testWidgets('FadeSlideIn shows content at once with reduced motion', (
    tester,
  ) async {
    reduceMotion(tester);
    await tester.pumpWidget(_host(const FadeSlideIn(child: Text('hello'))));
    await tester.pump();
    final opacity = find.ancestor(
      of: find.text('hello'),
      matching: find.byType(Opacity),
    );
    expect(tester.widget<Opacity>(opacity).opacity, 1);
  });

  testWidgets('AutoCarousel moves to the next image after the interval', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 300,
          height: 200,
          child: AutoCarousel(images: ['a.jpg', 'b.jpg', 'c.jpg']),
        ),
      ),
    );
    expect(find.byKey(const ValueKey(0)), findsOneWidget);

    // Step through time frame by frame, as a real screen does.
    final end = AppMotion.carouselInterval + AppMotion.long;
    for (
      var t = Duration.zero;
      t < end;
      t += const Duration(milliseconds: 100)
    ) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byKey(const ValueKey(1)), findsOneWidget);
    expect(find.byKey(const ValueKey(0)), findsNothing);
  });

  testWidgets('AutoCarousel stays on the first image with reduced motion', (
    tester,
  ) async {
    reduceMotion(tester);
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 300,
          height: 200,
          child: AutoCarousel(images: ['a.jpg', 'b.jpg']),
        ),
      ),
    );
    await tester.pump(AppMotion.carouselInterval * 2);
    expect(find.byKey(const ValueKey(0)), findsOneWidget);
  });
}
