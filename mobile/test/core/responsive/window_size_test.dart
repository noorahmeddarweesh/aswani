import 'package:aswani/core/responsive/window_size.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('window size classes follow Material 3 breakpoints', () {
    expect(WindowSize.fromWidth(360), WindowSize.compact);
    expect(WindowSize.fromWidth(599), WindowSize.compact);
    expect(WindowSize.fromWidth(600), WindowSize.medium);
    expect(WindowSize.fromWidth(839), WindowSize.medium);
    expect(WindowSize.fromWidth(840), WindowSize.expanded);
  });
}
