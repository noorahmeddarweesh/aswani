import 'dart:io';

import 'package:aswani/core/config/env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Settings > About shows the version in pubspec.yaml', () {
    final line = File('pubspec.yaml')
        .readAsLinesSync()
        .firstWhere((l) => l.startsWith('version:'));
    final version = line.split(':').last.trim().split('+').first;
    expect(Env.appVersion, version);
  });
}
