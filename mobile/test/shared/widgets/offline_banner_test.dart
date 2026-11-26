import 'dart:async';

import 'package:aswani/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('offline banner appears without a network and leaves after', (
    tester,
  ) async {
    reduceMotion(tester);
    // Broadcast: close() completes even when nobody is listening any more.
    final network = StreamController<bool>.broadcast();
    addTearDown(() => unawaited(network.close()));
    await tester.pumpWidget(
      ProviderScope(
        overrides: fastMocks(network: network.stream),
        child: const AswaniApp(),
      ),
    );

    network.add(false);
    await tester.pumpAndSettle();
    expect(find.textContaining("You're offline"), findsOneWidget);

    network.add(true);
    await tester.pumpAndSettle();
    expect(find.textContaining("You're offline"), findsNothing);
  });
}
