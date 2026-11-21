/// Pagination metadata matching `{ page, limit, total, total_pages }` from Contract v0.2.
class PageMetaDto {
  const PageMetaDto({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PageMetaDto.fromJson(Map<String, dynamic> json) => PageMetaDto(
    page: json['page'] as int? ?? 1,
    limit: json['limit'] as int? ?? 20,
    total: json['total'] as int? ?? 0,
    totalPages: json['total_pages'] as int? ?? 1,
  );

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  Map<String, dynamic> toJson() => {
    'page': page,
    'limit': limit,
    'total': total,
    'total_pages': totalPages,
  };
}

/// Generic wrapper for `{ "data": [...], "meta": {...} }`.
class PagedListDto<T> {
  const PagedListDto({required this.data, required this.meta});

  factory PagedListDto.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    final list = (json['data'] as List<dynamic>?) ?? const [];
    return PagedListDto(
      data: list
          .map((item) => itemFromJson(item as Map<String, dynamic>))
          .toList(),
      meta: json['meta'] is Map<String, dynamic>
          ? PageMetaDto.fromJson(json['meta'] as Map<String, dynamic>)
          : const PageMetaDto(page: 1, limit: 20, total: 0, totalPages: 1),
    );
  }

  final List<T> data;
  final PageMetaDto meta;

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) itemToJson) => {
    'data': data.map(itemToJson).toList(),
    'meta': meta.toJson(),
  };
}
