import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_settings.dart';
import 'core/l10n/generated/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/viewmodels/session_check.dart';
import 'shared/widgets/offline_banner.dart';

class AswaniApp extends ConsumerWidget {
  const AswaniApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Checks the saved session with the server once, in the background.
    ref.watch(sessionCheckProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      routerConfig: ref.watch(appRouterProvider),
      builder: (context, child) =>
          OfflineBanner(child: child ?? const SizedBox.shrink()),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      locale: ref.watch(localeProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      // material_ui ships its own Material/Cupertino/Widgets localisations;
      // the ones from flutter_localizations no longer reach material_ui widgets.
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
    );
  }
}
