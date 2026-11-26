import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/config/app_settings.dart';
import '../../../../core/network/upload.dart';
import '../../../../core/pagination/paged.dart';
import '../../../../core/result/result.dart';
import '../../../../core/session/session_controller.dart';
import '../../../auth/auth_providers.dart';
import '../../domain/entities/profile.dart';
import '../../profile_providers.dart';

T _value<T>(Result<T> result) => switch (result) {
  Success(:final value) => value,
  Error(:final failure) => throw failure,
};

/// The profile screen (one call). Also changes the profile photo.
class ProfileController extends AsyncNotifier<Profile> {
  @override
  Future<Profile> build() async =>
      _value(await ref.read(profileRepositoryProvider).getProfile());

  /// Uploads a new photo; returns the error code, or null when it worked.
  Future<String?> changeAvatar(UploadFile photo) async {
    final problem = checkUpload(photo);
    if (problem != null) return problem;
    final result = await ref
        .read(profileRepositoryProvider)
        .uploadAvatar(photo);
    if (!ref.mounted) return null;
    switch (result) {
      case Success(:final value):
        final profile = state.value;
        if (profile != null) state = AsyncData(profile.copyWith(avatar: value));
        ref.read(sessionProvider.notifier).avatarChanged(value);
        return null;
      case Error(:final failure):
        return failure.code;
    }
  }
}

final profileProvider =
    AsyncNotifierProvider.autoDispose<ProfileController, Profile>(
      ProfileController.new,
    );

/// "My saved content" (View all); [SavedType] null shows both.
final savedContentProvider = FutureProvider.autoDispose
    .family<Paged<SavedEntry>, SavedType?>(
      (ref, type) async => _value(
        await ref.read(profileRepositoryProvider).getSaved(type: type),
      ),
    );

/// Settings: language and notifications, plus Log out and Delete account.
class SettingsController extends AsyncNotifier<UserSettings> {
  @override
  Future<UserSettings> build() async {
    final saved = _value(
      await ref.read(profileRepositoryProvider).getSettings(),
    );
    // The phone's choice wins: the app may have been switched offline.
    return saved.copyWith(languageCode: ref.read(localeProvider).languageCode);
  }

  /// Switches the app at once (layout direction too), then saves it.
  Future<String?> setLanguage(String code) async {
    ref.read(localeProvider.notifier).setLocale(Locale(code));
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(languageCode: code));
    }
    final result = await ref
        .read(profileRepositoryProvider)
        .updateSettings(languageCode: code);
    return switch (result) {
      Success() => null,
      // The app keeps the language; the server copy is fixed next time.
      Error(:final failure) => failure.code,
    };
  }

  /// Changes at once; rolls back and returns the error code if it fails.
  Future<String?> setNotifications({required bool enabled}) async {
    final current = state.value;
    if (current == null) return null;
    state = AsyncData(current.copyWith(notificationsEnabled: enabled));
    final result = await ref
        .read(profileRepositoryProvider)
        .updateSettings(notificationsEnabled: enabled);
    if (!ref.mounted) return null;
    switch (result) {
      case Success():
        return null;
      case Error(:final failure):
        state = AsyncData(current);
        return failure.code;
    }
  }

  /// Clears the tokens even if the call fails (contract); the router then
  /// goes to Welcome.
  Future<void> logOut() async {
    await ref.read(authRepositoryProvider).signOut();
    ref.read(sessionProvider.notifier).signOut();
  }

  /// Asks the server to delete the account, then logs out. Returns the
  /// error code if the request failed.
  Future<String?> requestDeletion() async {
    final result = await ref.read(profileRepositoryProvider).requestDeletion();
    switch (result) {
      case Success():
        await logOut();
        return null;
      case Error(:final failure):
        return failure.code;
    }
  }
}

final settingsProvider =
    AsyncNotifierProvider.autoDispose<SettingsController, UserSettings>(
      SettingsController.new,
    );
