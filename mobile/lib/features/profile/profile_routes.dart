import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/router/app_page.dart';
import '../../shared/extensions/context_x.dart';
import '../../shared/widgets/coming_soon_screen.dart';
import '../personalization/presentation/screens/edit_preferences_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/saved_content_screen.dart';
import 'presentation/screens/settings_screen.dart';

// Owner: Person B (Culture & Community). Only this file registers profile
// routes.

/// Settings pages that have no design yet (contract v0.2, open questions).
enum ComingSoonPage {
  editProfile(LucideIcons.user),
  changePassword(LucideIcons.lockKeyhole),
  emailContact(LucideIcons.send),
  privacy(LucideIcons.shieldCheck),
  security(LucideIcons.lockKeyhole),
  help(LucideIcons.messageCircle),
  terms(LucideIcons.fileText);

  const ComingSoonPage(this.icon);
  final IconData icon;

  String title(AppLocalizations l10n) => switch (this) {
    editProfile => l10n.profileEditProfile,
    changePassword => l10n.settingsChangePassword,
    emailContact => l10n.settingsEmailContact,
    privacy => l10n.settingsPrivacy,
    security => l10n.settingsSecurity,
    help => l10n.settingsHelp,
    terms => l10n.settingsTerms,
  };
}

abstract final class ProfileRoutes {
  /// The signed-in user's profile (Home > avatar).
  static const String profile = '/profile';

  /// My saved content > View all.
  static const String saved = '/profile/saved';
  static const String settings = '/profile/settings';

  /// Settings > Interests & personalization.
  static const String interests = '/profile/settings/interests';

  static String soon(ComingSoonPage page) => '/profile/soon/${page.name}';
}

/// Full-screen profile routes.
final List<RouteBase> profileRootRoutes = [
  GoRoute(
    path: ProfileRoutes.profile,
    pageBuilder: (_, state) => appPage(state, const ProfileScreen()),
    routes: [
      GoRoute(
        path: 'saved',
        pageBuilder: (_, state) => appPage(state, const SavedContentScreen()),
      ),
      GoRoute(
        path: 'settings',
        pageBuilder: (_, state) => appPage(state, const SettingsScreen()),
        routes: [
          GoRoute(
            path: 'interests',
            pageBuilder: (_, state) =>
                appPage(state, const EditPreferencesScreen()),
          ),
        ],
      ),
      GoRoute(
        path: 'soon/:page',
        pageBuilder: (context, state) {
          final page = ComingSoonPage.values
              .where((p) => p.name == state.pathParameters['page'])
              .firstOrNull;
          return appPage(
            state,
            ComingSoonScreen(
              title: page?.title(context.l10n) ?? context.l10n.profileTitle,
              icon: page?.icon ?? LucideIcons.user,
            ),
          );
        },
      ),
    ],
  ),
];
