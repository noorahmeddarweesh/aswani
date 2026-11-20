import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../domain/entities/post.dart';

/// The row of circles at the top of the feed: "Your moment" (new post) and
/// one circle per highlight, which filters the feed by its category.
class HighlightsRow extends StatelessWidget {
  const HighlightsRow({
    super.key,
    required this.highlights,
    required this.selected,
    required this.onSelect,
    required this.onNewPost,
  });

  final List<Highlight> highlights;
  final PostCategory? selected;
  final ValueChanged<PostCategory> onSelect;
  final VoidCallback onNewPost;

  static const double _circle = 56;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    // One-line labels: large text grows them a little, never off the row.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: SizedBox(
        height: _circle + 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          children: [
            _Bubble(
              label: context.l10n.communityYourMoment,
              selected: false,
              onTap: onNewPost,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.palette.selectedTint,
                  border: Border.all(color: context.palette.link, width: 1.5),
                ),
                child: Icon(LucideIcons.plus, color: context.palette.link),
              ),
            ),
            for (final h in highlights)
              _Bubble(
                label: h.title(lang),
                selected: h.category == selected,
                onTap: () => onSelect(h.category),
                child: ClipOval(child: AppImage(h.coverImage)),
              ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ring = selected ? context.colors.primary : context.palette.accentGold;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: AppRadii.mdAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: SizedBox(
            width: HighlightsRow._circle + 8,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: AppMotion.short,
                  width: HighlightsRow._circle,
                  height: HighlightsRow._circle,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ring, width: selected ? 2.5 : 2),
                  ),
                  child: child,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: context.text.bodySmall?.copyWith(
                    fontSize: 11,
                    letterSpacing: 0,
                    color: context.palette.ink,
                    fontWeight: selected ? FontWeight.w700 : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
