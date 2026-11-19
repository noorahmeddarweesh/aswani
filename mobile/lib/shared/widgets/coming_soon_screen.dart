import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_spacing.dart';
import '../extensions/context_x.dart';
import 'app_top_bar.dart';

/// Placeholder for tabs and pages whose design is not ready yet. Shows a
/// back button when it was opened on top of another page.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title, this.icon});

  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    return Scaffold(
      appBar: canPop ? const AppTopBar() : null,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: context.palette.surfaceMuted,
                    borderRadius: AppRadii.lgAll,
                  ),
                  child: Icon(
                    icon ?? LucideIcons.sparkles,
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(title, style: context.text.headlineMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.l10n.comingSoonTitle,
                  style: context.text.titleSmall?.copyWith(
                    color: context.palette.link,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.l10n.comingSoonBody,
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
