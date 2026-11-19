import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/responsive/window_size.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/circle_icon_button.dart';
import '../../../../shared/widgets/eyebrow.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../domain/entities/place.dart';
import '../viewmodels/explore_view_model.dart';
import '../widgets/place_list_tile.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.comingSoonTitle)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final filter = ref.watch(exploreViewModelProvider);
    final vm = ref.read(exploreViewModelProvider.notifier);
    final placesAsync = ref.watch(explorePlacesProvider);
    final places = applySearch(
      placesAsync.value ?? const <Place>[],
      filter.query,
      lang,
    );
    final pick = filter.category == null && filter.query.isEmpty
        ? places.where((p) => p.isEditorsPick).firstOrNull
        : null;

    final filters = <(PlaceCategory?, String)>[
      (null, l10n.filterAll),
      (PlaceCategory.history, l10n.filterHistory),
      (PlaceCategory.nubian, l10n.filterNubian),
      (PlaceCategory.nature, l10n.filterNature),
      (PlaceCategory.food, l10n.filterFood),
    ];

    final errorCode = placesAsync.hasError && !placesAsync.hasValue
        ? errorCodeOf(placesAsync.error!)
        : null;

    return Scaffold(
      body: SafeArea(
        child: MaxWidthBox(
          child: RefreshIndicator(
            onRefresh: vm.retry,
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.lg,
                    AppSpacing.md,
                    0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Eyebrow(l10n.exploreEyebrow),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              l10n.exploreTitle,
                              style: context.text.headlineLarge?.copyWith(
                                fontSize: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircleIconButton(
                        icon: LucideIcons.slidersHorizontal,
                        tooltip: l10n.exploreFilters,
                        size: 48,
                        onPressed: () => _comingSoon(context),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.lg,
                    AppSpacing.screen,
                    AppSpacing.md,
                  ),
                  child: TextField(
                    onChanged: vm.search,
                    textInputAction: TextInputAction.search,
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    decoration: InputDecoration(
                      hintText: l10n.exploreSearchHint,
                      fillColor: context.palette.surfaceMuted,
                      prefixIcon: Icon(
                        LucideIcons.search,
                        size: 20,
                        color: context.palette.textSecondary,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: AppSpacing.screenPadding,
                    itemCount: filters.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.xs),
                    itemBuilder: (context, i) {
                      final (category, label) = filters.elementAt(i);
                      return _FilterChip(
                        label: label,
                        selected: filter.category == category,
                        onTap: () => vm.selectCategory(category),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: AppSpacing.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (pick != null) ...[
                        _EditorsPickCard(place: pick),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                      SectionHeader(
                        title: l10n.explorePopular,
                        actionLabel: l10n.exploreViewMap,
                        onAction: () => _comingSoon(context),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      if (!placesAsync.hasValue && placesAsync.isLoading)
                        for (var i = 0; i < 3; i++)
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.xs,
                            ),
                            child: SkeletonBox(height: 72),
                          )
                      else if (errorCode != null)
                        ErrorState(
                          message: _errorMessage(context, errorCode),
                          onRetry: vm.retry,
                        )
                      else if (places.isEmpty)
                        EmptyState(message: l10n.exploreEmpty)
                      else
                        for (final place in places)
                          PlaceListTile(
                            place: place,
                            onBookmark: () => vm.toggleBookmark(place.id),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _errorMessage(BuildContext context, String code) =>
      code == 'NO_CONNECTION'
      ? context.l10n.errorNoConnection
      : context.l10n.errorUnknown;
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? colors.primary : colors.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? colors.primary : context.palette.border,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Center(
              child: Text(
                label,
                style: context.text.bodyMedium?.copyWith(
                  color: selected ? colors.onPrimary : context.palette.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditorsPickCard extends StatelessWidget {
  const _EditorsPickCard({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final onPhoto = context.colors.onPrimary;
    // Grows with the text (large system font sizes), never shorter than 210.
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 210),
      child: ClipRRect(
        borderRadius: AppRadii.xlAll,
        child: Stack(
          children: [
            Positioned.fill(child: AppImage(place.imagePath)),
            const Positioned.fill(child: PhotoScrim(strength: 0.8)),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 90),
                  Eyebrow(
                    context.l10n.exploreEditorsPick,
                    color: context.palette.accentGoldOnDark,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    place.name(lang),
                    style: context.text.displayMedium?.copyWith(color: onPhoto),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    place.tagline(lang),
                    style: context.text.bodyMedium?.copyWith(
                      color: onPhoto.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
