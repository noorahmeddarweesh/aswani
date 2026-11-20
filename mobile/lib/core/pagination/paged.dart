/// One page of a list endpoint (`{ "data": [...], "meta": {...} }`).
class Paged<T> {
  const Paged({
    required this.items,
    required this.page,
    required this.totalPages,
    this.total,
  });

  /// Reads `meta`; a list without `meta` is a single page.
  factory Paged.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) item,
  ) {
    final meta = json['meta'] as Map<String, dynamic>?;
    final data = json['data'] as List<dynamic>;
    return Paged(
      items: [for (final e in data) item(e as Map<String, dynamic>)],
      page: meta?['page'] as int? ?? 1,
      totalPages: meta?['total_pages'] as int? ?? 1,
      total: meta?['total'] as int?,
    );
  }

  final List<T> items;
  final int page;
  final int totalPages;
  final int? total;

  bool get hasMore => page < totalPages;

  Paged<R> map<R>(R Function(T) convert) => Paged(
    items: items.map(convert).toList(),
    page: page,
    totalPages: totalPages,
    total: total,
  );
}

/// Page size used by every list screen (contract: default 20, max 50).
const int kPageSize = 20;
