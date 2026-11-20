import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/result/result.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../domain/entities/preferences.dart';
import '../../personalization_providers.dart';
import '../viewmodels/personalization_view_model.dart';
import 'personalization_screen.dart';

/// Settings > Interests & personalization: the same 8 steps, filled in with
/// the saved answers (GET /api/users/preferences).
class EditPreferencesScreen extends ConsumerStatefulWidget {
  const EditPreferencesScreen({super.key});

  @override
  ConsumerState<EditPreferencesScreen> createState() =>
      _EditPreferencesScreenState();
}

class _EditPreferencesScreenState extends ConsumerState<EditPreferencesScreen> {
  String? _error;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    final result = await ref.read(preferencesRepositoryProvider).load();
    if (!mounted) return;
    switch (result) {
      case Success(:final value):
        ref
            .read(personalizationViewModelProvider.notifier)
            .startEditing(value ?? const Preferences());
        setState(() => _ready = true);
      case Error(:final failure):
        setState(() => _error = failure.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keeps the edit state alive while this page is open.
    ref.watch(personalizationViewModelProvider.select((s) => s.editing));
    if (_ready) return const PersonalizationScreen();
    return Scaffold(
      appBar: const AppTopBar(),
      body: _error == null
          ? const Center(child: CircularProgressIndicator())
          : ErrorState(message: context.l10n.errorFor(_error!), onRetry: _load),
    );
  }
}
