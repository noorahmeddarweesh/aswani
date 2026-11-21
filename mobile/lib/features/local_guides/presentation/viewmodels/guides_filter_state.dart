import '../../domain/entities/guide.dart';
import '../../domain/entities/guide_enums.dart';
import '../../domain/entities/page_meta.dart';

/// Filter state for Local Guides screen.
/// Initial specialty is Nubian culture per tour_guides.jpg specification.
class GuidesFilter {
  const GuidesFilter({
    this.specialty = GuideSpecialty.nubianCulture,
    this.query = '',
  });

  final GuideSpecialty? specialty;
  final String query;

  GuidesFilter copyWith({
    GuideSpecialty? specialty,
    bool clearSpecialty = false,
    String? query,
  }) {
    return GuidesFilter(
      specialty: clearSpecialty ? null : (specialty ?? this.specialty),
      query: query ?? this.query,
    );
  }
}

/// Paginated guides list state holding items and metadata.
class GuidesListState {
  const GuidesListState({
    this.guides = const [],
    this.meta = const PageMeta(page: 1, limit: 20, total: 0, totalPages: 1),
    this.isLoadingMore = false,
  });

  final List<Guide> guides;
  final PageMeta meta;
  final bool isLoadingMore;

  Guide? get featuredGuide => guides.where((g) => g.isFeatured).firstOrNull;

  List<Guide> get suggestedGuides =>
      guides.where((g) => !g.isFeatured).toList();

  bool get hasMore => meta.hasNextPage;

  GuidesListState copyWith({
    List<Guide>? guides,
    PageMeta? meta,
    bool? isLoadingMore,
  }) {
    return GuidesListState(
      guides: guides ?? this.guides,
      meta: meta ?? this.meta,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
