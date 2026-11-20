import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/eyebrow.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/bookmark_icon.dart';
import '../../../../shared/widgets/motion.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../domain/entities/story.dart';
import '../viewmodels/culture_view_models.dart';

extension CultureThemeLabel on CultureTheme {
  String label(AppLocalizations l10n) => switch (this) {
    CultureTheme.nubianHeritage => l10n.cultureThemeNubianHeritage,
    CultureTheme.ancientHistory => l10n.cultureThemeAncientHistory,
    CultureTheme.traditions => l10n.cultureThemeTraditions,
    CultureTheme.artsCrafts => l10n.cultureThemeArtsCrafts,
  };
}

String _lang(BuildContext context) =>
    Localizations.localeOf(context).languageCode;

/// Saves or un-saves a story and tells the user if that failed.
Future<void> toggleStorySave(
  BuildContext context,
  WidgetRef ref,
  StorySummary story,
) async {
  final error = await ref.read(storySavesProvider.notifier).toggle(story);
  if (error == null || !context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(context.l10n.errorFor(error))));
}

/// The large story card at the top of Culture home.
class FeaturedStoryCard extends StatelessWidget {
  const FeaturedStoryCard({
    super.key,
    required this.story,
    required this.onTap,
  });

  final StorySummary story;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = _lang(context);
    final onDark = context.palette.onBrandSurface;
    final meta = [
      if (story.isSample) l10n.cultureSampleEditorial,
      l10n.cultureMinRead(story.readMinutes),
    ].join(' • ');
    return PressableScale(
      child: GestureDetector(
        onTap: onTap,
        child: Semantics(
          button: true,
          label: story.title(lang),
          child: ClipRRect(
            borderRadius: AppRadii.xlAll,
            // At least the photo's shape; taller when large text needs it.
            child: LayoutBuilder(
              builder: (context, constraints) => ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxWidth / 1.18,
                ),
                child: Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    Positioned.fill(child: AppImage(story.coverImage)),
                    const Positioned.fill(child: PhotoScrim(strength: 0.85)),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story.label(lang).toUpperCase(),
                            style: context.text.labelSmall?.copyWith(
                              color: context.palette.accentGoldOnDark,
                              letterSpacing: lang == 'ar' ? 0 : 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            story.title(lang),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.headlineMedium?.copyWith(
                              color: onDark,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            meta,
                            style: context.text.bodySmall?.copyWith(
                              color: onDark.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A theme tile of "Browse by theme".
class ThemeTile extends StatelessWidget {
  const ThemeTile({
    super.key,
    required this.title,
    required this.image,
    required this.onTap,
  });

  final String title;
  final String image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      child: GestureDetector(
        onTap: onTap,
        child: Semantics(
          button: true,
          label: title,
          excludeSemantics: true,
          child: ClipRRect(
            borderRadius: AppRadii.lgAll,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppImage(image),
                const PhotoScrim(strength: 0.7),
                PositionedDirectional(
                  start: AppSpacing.sm,
                  end: AppSpacing.sm,
                  bottom: AppSpacing.sm,
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleSmall?.copyWith(
                      color: context.palette.onBrandSurface,
                    ),
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

/// A story in a list: photo, label line, title, place and a save button.
class StoryListTile extends ConsumerWidget {
  const StoryListTile({super.key, required this.story, required this.onTap});

  final StorySummary story;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lang = _lang(context);
    ref.watch(storySavesProvider);
    final saved = ref.read(storySavesProvider.notifier).isSaved(story);
    final place = story.location(lang);
    final label = [
      story.label(lang),
      if (story.isSample) l10n.cultureSampleContent,
    ].join(' • ');
    return InkWell(
      borderRadius: AppRadii.lgAll,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: AppRadii.lgAll,
              child: SizedBox(
                width: 90,
                height: 84,
                child: AppImage(story.coverImage),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(
                      fontSize: 11,
                      color: context.palette.link,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    story.title(lang),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleLarge?.copyWith(fontSize: 16),
                  ),
                  if (place != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.mapPin,
                          size: 12,
                          color: context.palette.textSecondary,
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            place,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.bodySmall?.copyWith(
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: saved ? l10n.cultureUnsave : l10n.cultureSave,
              onPressed: () => toggleStorySave(context, ref, story),
              icon: BookmarkIcon(saved: saved),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder rows while a list of stories loads.
class StoryListSkeleton extends StatelessWidget {
  const StoryListSkeleton({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < count; i++)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                SkeletonBox(
                  width: 90,
                  height: 84,
                  borderRadius: AppRadii.lgAll,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 120, height: 10),
                      SizedBox(height: AppSpacing.xs),
                      SkeletonBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// "Memory of the place": the title and one line under it, above the
/// featured story.
class CultureHeader extends StatelessWidget {
  const CultureHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.4,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow(l10n.cultureEyebrow, color: context.palette.link),
            const SizedBox(height: AppSpacing.xxs),
            Text(l10n.cultureHeadline, style: context.text.headlineLarge),
            const SizedBox(height: AppSpacing.xxs),
            Text(l10n.cultureIntro, style: context.text.bodyMedium),
          ],
        ),
      ),
    );
  }
}
