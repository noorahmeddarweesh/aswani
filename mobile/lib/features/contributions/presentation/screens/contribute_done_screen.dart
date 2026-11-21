import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/responsive/window_size.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/motion.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../contributions_routes.dart';
import '../widgets/contribute_widgets.dart';

/// "Contribution received".
class ContributeDoneScreen extends StatelessWidget {
  const ContributeDoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: MaxWidthBox(
          maxWidth: 560,
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: staggered([
                        const SizedBox(height: AppSpacing.xxxl * 1.5),
                        const IconBadge(icon: LucideIcons.sparkles, gold: true),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l10n.contributeReceivedTitle,
                          textAlign: TextAlign.center,
                          style: context.text.headlineMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.contributeReceivedBody,
                          textAlign: TextAlign.center,
                          style: context.text.bodyMedium,
                        ),
                      ]),
                    ),
                  ),
                ),
                // Where to follow it later.
                Text(
                  l10n.contributeTrackNote,
                  textAlign: TextAlign.center,
                  style: context.text.bodySmall,
                ),
                TextButton(
                  onPressed: () => context.push(ContributeRoutes.mine),
                  child: Text(l10n.contributeTrackAction),
                ),
                const SizedBox(height: AppSpacing.xs),
                PrimaryButton(
                  label: l10n.backToHome,
                  onPressed: () => context.go(AppRoutes.home),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
