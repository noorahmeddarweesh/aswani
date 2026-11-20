import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/result/result.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../contributions_providers.dart';
import '../viewmodels/contribute_view_model.dart';
import 'contribute_details_screen.dart';

/// Added activities > Edit: the details form filled with what was sent
/// (GET /contributions/{id}), then Preview and "Send changes"
/// (PATCH, contract v0.3). The activity is reviewed again.
class EditContributionScreen extends ConsumerStatefulWidget {
  const EditContributionScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<EditContributionScreen> createState() =>
      _EditContributionScreenState();
}

class _EditContributionScreenState
    extends ConsumerState<EditContributionScreen> {
  String? _error;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    final result = await ref
        .read(contributionsRepositoryProvider)
        .getOne(widget.id);
    if (!mounted) return;
    switch (result) {
      case Success(:final value):
        ref.read(contributeProvider.notifier).startEditing(value);
        setState(() => _ready = true);
      case Error(:final failure):
        setState(() => _error = failure.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keeps the form alive while Preview is open on top of this page.
    ref.watch(contributeProvider.select((s) => s.editingId));
    ref.listen(contributeProvider.select((s) => s.saved), (_, saved) {
      if (!saved) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.l10n.contributeEdited)));
      if (context.canPop()) context.pop();
    });
    if (_ready) return const ContributeDetailsScreen();
    return Scaffold(
      appBar: AppTopBar(title: context.l10n.contributeEditTitle),
      body: _error == null
          ? const Center(child: CircularProgressIndicator())
          : ErrorState(message: context.l10n.errorFor(_error!), onRetry: _load),
    );
  }
}
