import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/config/app_settings.dart';
import '../../../../core/config/env.dart';
import '../../../../core/errors/error_messages.dart';
import '../../../../core/responsive/window_size.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/confirm_sheet.dart';
import '../../../../shared/widgets/motion.dart';
import '../../profile_routes.dart';
import '../viewmodels/profile_view_models.dart';
import '../widgets/settings_widgets.dart';

/// Settings (Profile > gear).
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _busy = false;

  void _show(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  void _soon(ComingSoonPage page) => context.push(ProfileRoutes.soon(page));

  Future<void> _setLanguage(String code) async {
    final error = await ref.read(settingsProvider.notifier).setLanguage(code);
    if (error != null && mounted) _show(context.l10n.errorFor(error));
  }

  Future<void> _setNotifications(bool enabled) async {
    final error = await ref
        .read(settingsProvider.notifier)
        .setNotifications(enabled: enabled);
    if (error != null && mounted) _show(context.l10n.errorFor(error));
  }

  Future<void> _logOut() async {
    final l10n = context.l10n;
    final ok = await showConfirmSheet(
      context,
      title: l10n.settingsLogOutTitle,
      message: l10n.settingsLogOutMessage,
      confirmLabel: l10n.settingsLogOut,
      icon: LucideIcons.logOut,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    // The router sends a signed-out user to Welcome.
    await ref.read(settingsProvider.notifier).logOut();
  }

  Future<void> _deleteAccount() async {
    final l10n = context.l10n;
    final ok = await showConfirmSheet(
      context,
      title: l10n.settingsDeleteTitle,
      message: l10n.settingsDeleteMessage,
      confirmLabel: l10n.settingsDeleteConfirm,
      icon: LucideIcons.x,
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final error = await ref.read(settingsProvider.notifier).requestDeletion();
    if (!mounted) return;
    setState(() => _busy = false);
    if (error != null) _show(l10n.errorFor(error));
  }

  void _about() => showAboutDialog(
    context: context,
    applicationName: 'ASWANI',
    applicationVersion: context.l10n.settingsVersion(Env.appVersion),
  );

  void _location() => showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(LucideIcons.mapPin, color: context.palette.link),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.settingsLocation,
            textAlign: TextAlign.center,
            style: context.text.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.settingsLocationInfo,
            textAlign: TextAlign.center,
            style: context.text.bodyMedium,
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    // The language shows at once from the phone; the rest from the server.
    final language = ref.watch(localeProvider).languageCode;
    final settings = ref.watch(settingsProvider);
    final notifications = settings.value?.notificationsEnabled;

    return Scaffold(
      appBar: AppTopBar(title: l10n.settingsTitle),
      body: MaxWidthBox(
        maxWidth: 640,
        child: AbsorbPointer(
          absorbing: _busy,
          child: ListView(
            padding: AppSpacing.screenPadding.copyWith(
              top: AppSpacing.xs,
              bottom: AppSpacing.xxl,
            ),
            children: staggered([
              SettingsGroup(
                title: l10n.settingsAccount,
                children: [
                  SettingsTile(
                    icon: LucideIcons.user,
                    title: l10n.profileEditProfile,
                    onTap: () => _soon(ComingSoonPage.editProfile),
                  ),
                  SettingsTile(
                    icon: LucideIcons.lockKeyhole,
                    title: l10n.settingsChangePassword,
                    onTap: () => _soon(ComingSoonPage.changePassword),
                  ),
                  SettingsTile(
                    icon: LucideIcons.send,
                    title: l10n.settingsEmailContact,
                    onTap: () => _soon(ComingSoonPage.emailContact),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SettingsGroup(
                title: l10n.settingsAppPreferences,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              LucideIcons.languages,
                              size: 22,
                              color: palette.link,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.settingsLanguage,
                                    style: context.text.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: palette.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    l10n.settingsLanguageHint,
                                    style: context.text.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        LanguageSegment(
                          languageCode: language,
                          onChanged: _setLanguage,
                        ),
                      ],
                    ),
                  ),
                  SettingsTile(
                    icon: LucideIcons.bell,
                    title: l10n.settingsNotifications,
                    onTap: notifications == null
                        ? null
                        : () => _setNotifications(!notifications),
                    trailing: notifications == null
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Switch(
                            activeTrackColor: palette.link,
                            value: notifications,
                            onChanged: _setNotifications,
                          ),
                  ),
                  SettingsTile(
                    icon: LucideIcons.mapPin,
                    title: l10n.settingsLocation,
                    onTap: _location,
                  ),
                  SettingsTile(
                    icon: LucideIcons.sparkles,
                    title: l10n.settingsInterests,
                    onTap: () => context.push(ProfileRoutes.interests),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SettingsGroup(
                title: l10n.settingsPrivacySecurity,
                children: [
                  SettingsTile(
                    icon: LucideIcons.shieldCheck,
                    title: l10n.settingsPrivacy,
                    onTap: () => _soon(ComingSoonPage.privacy),
                  ),
                  SettingsTile(
                    icon: LucideIcons.lockKeyhole,
                    title: l10n.settingsSecurity,
                    onTap: () => _soon(ComingSoonPage.security),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SettingsGroup(
                title: l10n.settingsSupport,
                children: [
                  SettingsTile(
                    icon: LucideIcons.messageCircle,
                    title: l10n.settingsHelp,
                    onTap: () => _soon(ComingSoonPage.help),
                  ),
                  SettingsTile(
                    leading: const _AboutBadge(),
                    title: l10n.settingsAbout,
                    value: Env.appVersion,
                    onTap: _about,
                  ),
                  SettingsTile(
                    icon: LucideIcons.fileText,
                    title: l10n.settingsTerms,
                    onTap: () => _soon(ComingSoonPage.terms),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: TextButton(
                  onPressed: _logOut,
                  child: Text(l10n.settingsLogOut),
                ),
              ),
              Center(
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: context.colors.error,
                  ),
                  onPressed: _deleteAccount,
                  child: Text(l10n.settingsDeleteAccount),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// The small gold "A" of the design next to "About ASWANI".
class _AboutBadge extends StatelessWidget {
  const _AboutBadge();

  @override
  Widget build(BuildContext context) {
    final gold = context.palette.accentGold;
    return Container(
      width: 34,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: gold),
      ),
      child: Text(
        'A',
        style: context.text.labelSmall?.copyWith(
          color: gold,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
