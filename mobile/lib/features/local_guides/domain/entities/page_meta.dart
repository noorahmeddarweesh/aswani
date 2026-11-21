/// Metadata for paginated list responses per Contract v0.2.
class PageMeta {
  const PageMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
}

/// Generic container for a paginated list of items with pagination metadata.
class PagedList<T> {
  const PagedList({
    required this.data,
    required this.meta,
  });

  final List<T> data;
  final PageMeta meta;
}
