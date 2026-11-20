import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/eyebrow.dart';

/// "From people, for people / Aswani community" with the New post button.
/// It hides as the feed scrolls down and comes back on a small scroll up.
class CommunityHeader extends StatelessWidget {
  const CommunityHeader({super.key, required this.onNewPost});

  final VoidCallback onNewPost;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Large text grows the title a little; the header must stay a header.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: _header(context, l10n),
    );
  }

  Widget _header(BuildContext context, AppLocalizations l10n) {
    return ColoredBox(
      color: context.colors.surface,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.screen,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow(l10n.communityEyebrow, color: context.palette.link),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(l10n.communityTitle, style: context.text.headlineLarge),
                ],
              ),
            ),
            Tooltip(
              message: l10n.communityNewPost,
              child: Material(
                color: context.palette.surfaceMuted,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onNewPost,
                  child: SizedBox.square(
                    dimension: 52,
                    child: Icon(
                      LucideIcons.plus,
                      size: 26,
                      color: context.colors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
