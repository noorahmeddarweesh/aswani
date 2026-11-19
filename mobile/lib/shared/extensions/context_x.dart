import 'package:material_ui/material_ui.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/responsive/window_size.dart';
import '../../core/theme/app_palette.dart';

/// Short, consistent access to theme, strings and screen size.
///
/// ```dart
/// Text(context.l10n.signIn, style: context.text.titleMedium);
/// Container(color: context.palette.surfaceMuted);
/// ```
extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
  AppLocalizations get l10n => AppLocalizations.of(this);
  WindowSize get windowSize => WindowSize.of(this);
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
}
