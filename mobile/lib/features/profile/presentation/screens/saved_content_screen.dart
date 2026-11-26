import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/responsive/window_size.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../culture/culture_routes.dart';
import '../../../places/places_routes.dart';
import '../../domain/entities/profile.dart';
import '../viewmodels/profile_view_models.dart';

/// "My saved content" > View all: saved places and stories, newest first.
class SavedContentScreen extends ConsumerStatefulWidget {
  const SavedContentScreen({super.key});

  @override
  ConsumerState<SavedContentScreen> createState() => _SavedContentScreenState();
}

class _SavedContentScreenState extends ConsumerState<SavedContentScreen> {
  SavedType? _type;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final saved = ref.watch(savedContentProvider(_type));
    final filters = [
      (null, l10n.profileFilterAll),
      (SavedType.place, l10n.profileFilterPlaces),
      (SavedType.story, l10n.profileFilterStories),
    ];

    return Scaffold(
      appBar: AppTopBar(title: l10n.profileSavedContent),
      body: MaxWidthBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: AppSpacing.screenPadding.copyWith(
                top: AppSpacing.xxs,
                bottom: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  for (final (type, label) in filters)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        end: AppSpacing.xs,
                      ),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: _type == type,
                        onSelected: (_) => setState(() => _type = type),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: saved.when(
                skipLoadingOnReload: true,
                loading: () => const _GridSkeleton(),
                error: (error, _) => ErrorState(
                  message: l10n.errorFor(
                    error is Failure ? error.code : ErrorCodes.unknown,
                  ),
                  onRetry: () => ref.invalidate(savedContentProvider(_type)),
                ),
                data: (page) => page.items.isEmpty
                    ? EmptyState(
                        message: l10n.profileSavedEmpty,
                        icon: LucideIcons.bookmark,
                      )
                    : _SavedGrid(items: page.items),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedGrid extends StatelessWidget {
  const _SavedGrid({required this.items});

  final List<SavedEntry> items;

  @override
  Widget build(BuildContext context) {
    final columns = switch (WindowSize.of(context)) {
      WindowSize.compact => 2,
      WindowSize.medium => 3,
      WindowSize.expanded => 4,
    };
    return GridView.builder(
      padding: AppSpacing.screenPadding.copyWith(bottom: AppSpacing.xxl),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.72,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => _SavedCard(entry: items[i]),
    );
  }
}

class _SavedCard extends StatelessWidget {
  const _SavedCard({required this.entry});

  final SavedEntry entry;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final isStory = entry.type == SavedType.story;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadii.lgAll,
        onTap: () => context.push(
          isStory
              ? CultureRoutes.story(entry.id)
              : PlacesRoutes.place(entry.id),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: AppRadii.lgAll,
                    child: AppImage(entry.image),
                  ),
                  PositionedDirectional(
                    top: AppSpacing.xs,
                    start: AppSpacing.xs,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isStory ? LucideIcons.bookOpen : LucideIcons.mapPin,
                        size: 14,
                        color: context.palette.link,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              entry.title(lang),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
            Text(
              entry.label(lang),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _GridSkeleton extends StatelessWidget {
  const _GridSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: SkeletonBox(height: 180)),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: SkeletonBox(height: 180)),
            ],
          ),
        ],
      ),
    );
  }
}
