import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/responsive/window_size.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/utils/share.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/bookmark_icon.dart';
import '../../../../shared/widgets/motion.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../domain/entities/story.dart';
import '../viewmodels/culture_view_models.dart';
import '../widgets/culture_widgets.dart';

/// "Cultural story": cover, title, reading time, then the blocks in the
/// app's language. Save from the top bar.
class StoryScreen extends ConsumerWidget {
  const StoryScreen({super.key, required this.storyId});

  final String storyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final story = ref.watch(storyProvider(storyId));
    ref.watch(storySavesProvider);
    final summary = story.value?.summary;
    final saved =
        summary != null &&
        ref.read(storySavesProvider.notifier).isSaved(summary);

    return Scaffold(
      appBar: AppTopBar(
        title: l10n.cultureStoryTitle,
        trailing: summary == null
            ? null
            : IconButton(
                tooltip: saved ? l10n.cultureUnsave : l10n.cultureSave,
                onPressed: () => toggleStorySave(context, ref, summary),
                icon: BookmarkIcon(saved: saved, size: 22),
              ),
      ),
      body: story.when(
        loading: () => const Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            children: [
              AspectRatio(aspectRatio: 1.35, child: SkeletonBox()),
              SizedBox(height: AppSpacing.lg),
              SkeletonBox(height: 28),
              SizedBox(height: AppSpacing.sm),
              SkeletonBox(height: 14),
            ],
          ),
        ),
        error: (error, _) => ErrorState(
          message: l10n.errorFor(
            error is Failure ? error.code : ErrorCodes.unknown,
          ),
          onRetry: () => ref.invalidate(storyProvider(storyId)),
        ),
        data: (data) {
          final s = data.summary;
          final eyebrow = [
            s.label(lang).toUpperCase(),
            if (s.isSample) l10n.cultureSample.toUpperCase(),
          ].join(' • ');
          return MaxWidthBox(
            maxWidth: 680,
            child: ListView(
              padding: AppSpacing.screenPadding.copyWith(
                top: AppSpacing.xs,
                bottom: AppSpacing.xxxl,
              ),
              children: staggered([
                ClipRRect(
                  borderRadius: AppRadii.xlAll,
                  child: AspectRatio(
                    aspectRatio: 1.35,
                    child: AppImage(s.coverImage),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  eyebrow,
                  style: context.text.labelSmall?.copyWith(
                    color: context.palette.accentGold,
                    letterSpacing: lang == 'ar' ? 0 : 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(s.title(lang), style: context.text.headlineLarge),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.cultureMinRead(s.readMinutes),
                        style: context.text.bodySmall,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          shareText(l10n.cultureShareText(s.title(lang))),
                      icon: const Icon(LucideIcons.share2, size: 16),
                      label: Text(l10n.share),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: AppSpacing.sm),
                for (final block in data.blocks)
                  _Block(block: block, lang: lang),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.block, required this.lang});

  final StoryBlock block;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final ink = context.palette.ink;
    final body = text.bodyLarge?.copyWith(
      color: context.palette.textSecondary,
      height: 1.7,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: switch (block.type) {
        StoryBlockType.lead => Text(
          block.text(lang),
          style: text.titleLarge?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
        StoryBlockType.paragraph => Text(block.text(lang), style: body),
        StoryBlockType.heading => Text(
          block.text(lang),
          style: text.headlineSmall?.copyWith(color: ink),
        ),
        StoryBlockType.quote => Container(
          padding: const EdgeInsetsDirectional.only(start: AppSpacing.md),
          decoration: BoxDecoration(
            border: BorderDirectional(
              start: BorderSide(color: context.palette.accentGold, width: 3),
            ),
          ),
          child: Text(
            block.text(lang),
            style: text.titleLarge?.copyWith(
              color: context.colors.primary,
              height: 1.5,
            ),
          ),
        ),
        StoryBlockType.image => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: AppRadii.lgAll,
              child: AspectRatio(
                aspectRatio: 1.6,
                child: AppImage(block.image ?? ''),
              ),
            ),
            if (block.caption(lang) case final caption?) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(caption, style: text.bodySmall),
            ],
          ],
        ),
      },
    );
  }
}
