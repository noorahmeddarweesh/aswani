import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/responsive/window_size.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/eyebrow.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../domain/entities/guide.dart';
import '../local_guides_strings.dart';
import '../viewmodels/guides_view_model.dart';
import '../widgets/become_guide_cta_card.dart';
import '../widgets/featured_guide_card.dart';
import '../widgets/guides_search_bar.dart';
import '../widgets/specialty_filter_chips.dart';
import '../widgets/suggested_guide_card.dart';

/// Local Guides main list screen matching tour_guides.jpg:
/// - Eyebrow: LOCAL KNOWLEDGE
/// - Title: Explore Aswan with a local guide
/// - Subtitle: Find someone who knows its stories, culture, and hidden places.
/// - Search bar with filter icon
/// - Specialty chips (Nubian culture, Historical sites, Nile, Photography)
/// - Featured guide card
/// - Suggested guides list with Filter action
/// - "Know Aswan by heart?" CTA card
class GuidesScreen extends ConsumerStatefulWidget {
  const GuidesScreen({
    super.key,
    this.onGuideSelected,
    this.onApplyPressed,
    this.onFilterPressed,
  });

  final ValueChanged<Guide>? onGuideSelected;
  final VoidCallback? onApplyPressed;
  final VoidCallback? onFilterPressed;

  @override
  ConsumerState<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends ConsumerState<GuidesScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      ref.read(guidesListProvider.notifier).loadMore();
    }
  }

  void _handleGuideTap(Guide guide) {
    if (widget.onGuideSelected != null) {
      widget.onGuideSelected!(guide);
    } else {
      // Pending route integration: /guides/:id
    }
  }

  void _handleApplyTap() {
    if (widget.onApplyPressed != null) {
      widget.onApplyPressed!();
    } else {
      // Pending route integration: /guides/apply
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.guidesL10n;
    final filter = ref.watch(guidesFilterProvider);
    final filterVm = ref.read(guidesFilterProvider.notifier);
    final asyncGuides = ref.watch(guidesListProvider);
    final listVm = ref.read(guidesListProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: MaxWidthBox(
          child: RefreshIndicator(
            onRefresh: listVm.retry,
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              children: [
                // Top Header Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.lg,
                    AppSpacing.screen,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Eyebrow(l10n.eyebrow),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        l10n.title,
                        style: context.text.headlineLarge?.copyWith(
                          fontSize: 28,
                          height: 1.2,
                          color: context.palette.ink,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.subtitle,
                        style: context.text.bodyMedium?.copyWith(
                          color: context.palette.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screen,
                  ),
                  child: GuidesSearchBar(
                    controller: _searchController,
                    onChanged: filterVm.onSearchChanged,
                    onFilterPressed: widget.onFilterPressed,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Specialty Filter Chips
                SpecialtyFilterChips(
                  selectedSpecialty: filter.specialty,
                  onSelected: filterVm.toggleSpecialty,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Content Section based on AsyncValue state
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screen,
                  ),
                  child: asyncGuides.when(
                    loading: () => const _LoadingSkeleton(),
                    error: (error, _) => ErrorState(
                      message: l10n.errorLoading,
                      onRetry: listVm.retry,
                    ),
                    data: (state) {
                      if (state.guides.isEmpty) {
                        return EmptyState(
                          message: filter.query.isNotEmpty
                              ? l10n.emptySearch
                              : l10n.emptyFilter,
                        );
                      }

                      final featured = state.featuredGuide;
                      final suggested = state.suggestedGuides;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Featured Guide (only if present)
                          if (featured != null) ...[
                            FeaturedGuideCard(
                              guide: featured,
                              onTap: () => _handleGuideTap(featured),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                          ],

                          // Suggested Guides Section
                          if (suggested.isNotEmpty) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.suggestedSectionTitle,
                                    style: context.text.titleLarge?.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: context.palette.ink,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                GestureDetector(
                                  onTap: widget.onFilterPressed,
                                  child: Text(
                                    l10n.filterAction,
                                    style: context.text.labelMedium?.copyWith(
                                      color: context.palette.link,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            ...suggested.map((guide) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: SuggestedGuideCard(
                                  guide: guide,
                                  onTap: () => _handleGuideTap(guide),
                                ),
                              );
                            }),
                          ],

                          // Infinite scroll loading indicator
                          if (state.isLoadingMore) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: AppSpacing.md),

                          // CTA Card
                          BecomeGuideCtaCard(
                            onTap: _handleApplyTap,
                          ),
                        ],
                      );
                    },
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

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SkeletonBox(height: 180, borderRadius: AppRadii.xlAll),
        SizedBox(height: AppSpacing.xl),
        SkeletonBox(height: 80, borderRadius: AppRadii.lgAll),
        SizedBox(height: AppSpacing.sm),
        SkeletonBox(height: 80, borderRadius: AppRadii.lgAll),
      ],
    );
  }
}
