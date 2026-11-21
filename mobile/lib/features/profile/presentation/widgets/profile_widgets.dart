import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../domain/entities/profile.dart';

/// Round photo with the small pen badge of the design.
class EditableAvatar extends StatelessWidget {
  const EditableAvatar({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.onEdit,
    this.busy = false,
  });

  final String name;
  final String? imageUrl;
  final VoidCallback? onEdit;
  final bool busy;

  static const double size = 88;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: context.l10n.profileChangePhoto,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: busy ? null : onEdit,
        child: SizedBox.square(
          dimension: size + 4,
          child: Stack(
            children: [
              UserAvatar(
                name: name,
                imageUrl: imageUrl,
                size: size,
                ring: true,
              ),
              if (busy)
                const Positioned.fill(
                  child: Center(child: CircularProgressIndicator()),
                ),
              PositionedDirectional(
                end: 0,
                bottom: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.surface, width: 2),
                  ),
                  child: Icon(
                    LucideIcons.penLine,
                    size: 14,
                    color: colors.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Saved places | Saved stories | Posts | Points.
class ProfileStatsCard extends StatelessWidget {
  const ProfileStatsCard({super.key, required this.stats});

  final ProfileStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (stats.savedPlaces, l10n.profileStatSavedPlaces),
      (stats.savedStories, l10n.profileStatSavedStories),
      (stats.posts, l10n.profileStatPosts),
      (stats.points, l10n.profileStatPoints),
    ];
    // Four numbers side by side: grow text only so far, or labels break
    // into single letters on small phones.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.4,
      child: _card(context, items),
    );
  }

  Widget _card(BuildContext context, List<(int, String)> items) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: context.palette.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (final (i, (value, label)) in items.indexed) ...[
              if (i > 0)
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  indent: AppSpacing.xxs,
                  endIndent: AppSpacing.xxs,
                  color: context.palette.divider,
                ),
              Expanded(
                child: Semantics(
                  container: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$value',
                          style: context.text.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.palette.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: context.text.bodySmall?.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The three photos under "My saved content": the first one a bit wider.
class SavedPreviewStrip extends StatelessWidget {
  const SavedPreviewStrip({
    super.key,
    required this.items,
    required this.onTap,
  });

  final List<SavedPreview> items;
  final ValueChanged<SavedPreview> onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // As tall as the design on a phone, never taller than a third of a
        // wide screen.
        final height = (constraints.maxWidth * 0.58).clamp(140.0, 260.0);
        return ClipRRect(
          borderRadius: AppRadii.lgAll,
          child: SizedBox(
            height: height,
            child: Row(
              children: [
                for (final (i, item) in items.indexed) ...[
                  if (i > 0) const SizedBox(width: 5),
                  Expanded(
                    flex: i == 0 ? 13 : 10,
                    child: Material(
                      child: InkWell(
                        onTap: () => onTap(item),
                        child: Ink(
                          child: AppImage(item.image, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// "160 points earned · 1 report under review" on a warm card.
class PointsCard extends StatelessWidget {
  const PointsCard({
    super.key,
    required this.points,
    required this.underReview,
    required this.onTap,
  });

  final int points;
  final int underReview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gold = context.palette.accentGold;
    return Material(
      color: gold.withValues(alpha: 0.1),
      borderRadius: AppRadii.lgAll,
      child: InkWell(
        borderRadius: AppRadii.lgAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(Icons.star_rounded, color: gold, size: 28),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.profilePointsEarned(points),
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.palette.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.profileReportsUnderReview(underReview),
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRightDir,
                size: 20,
                color: context.palette.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// My posts / Added activities / Guide requests.
class ProfileLinkRow extends StatelessWidget {
  const ProfileLinkRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.palette.divider)),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 2),
              child: Icon(icon, size: 22, color: context.palette.link),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.palette.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: context.text.bodySmall),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRightDir,
              size: 20,
              color: context.palette.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
