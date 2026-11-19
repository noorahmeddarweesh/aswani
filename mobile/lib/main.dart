import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'core/storage/app_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Restores language, theme and session before the first frame, so a
  // signed-in user lands directly on Home.
  final overrides = await bootstrapStorage();
  runApp(ProviderScope(overrides: overrides, child: const AswaniApp()));
}
