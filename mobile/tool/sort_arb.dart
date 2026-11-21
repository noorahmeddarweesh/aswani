// Sorts lib/core/l10n/app_*.arb alphabetically (each "@key" stays under its
// key). Sorted files mean two people adding strings rarely touch the same
// lines, so merges seldom conflict.
//
// Run from mobile/:  dart run tool/sort_arb.dart
// Check only (CI):   dart run tool/sort_arb.dart --check
import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final check = args.contains('--check');
  var unsorted = false;
  final files = Directory('lib/core/l10n')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.arb'));
  for (final file in files) {
    final text = file.readAsStringSync();
    final data = jsonDecode(text) as Map<String, dynamic>;
    final keys = data.keys.where((k) => !k.startsWith('@')).toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final sorted = <String, dynamic>{
      for (final k in data.keys.where((k) => k.startsWith('@@'))) k: data[k],
    };
    for (final k in keys) {
      sorted[k] = data[k];
      if (data.containsKey('@$k')) sorted['@$k'] = data['@$k'];
    }
    final out = '${const JsonEncoder.withIndent('  ').convert(sorted)}\n';
    if (out != text) {
      unsorted = true;
      if (check) {
        stderr.writeln(
          '${file.path} is not sorted: dart run tool/sort_arb.dart',
        );
      } else {
        file.writeAsStringSync(out);
        stdout.writeln('sorted ${file.path}');
      }
    }
  }
  if (check && unsorted) exit(1);
}
