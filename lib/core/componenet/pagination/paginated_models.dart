int _asInt(dynamic value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value.trim());
    if (parsed != null) {
      return parsed;
    }
  }
  return fallback;
}

class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.initial({int limit = 20}) {
    return PaginationMeta(page: 0, limit: limit, total: 0, totalPages: 1);
  }

  factory PaginationMeta.fromJson(
    dynamic json, {
    int fallbackPage = 1,
    int fallbackLimit = 20,
    int fallbackTotal = 0,
  }) {
    if (json is! Map) {
      return PaginationMeta(
        page: fallbackPage,
        limit: fallbackLimit,
        total: fallbackTotal,
        totalPages: fallbackTotal == 0 ? 1 : fallbackPage,
      );
    }

    final map = Map<String, dynamic>.from(json);
    final total = _asInt(map['total'], fallbackTotal);
    final limit = _asInt(map['limit'], fallbackLimit);
    final page = _asInt(map['page'], fallbackPage);
    final totalPages = _asInt(
      map['totalPages'],
      total == 0 ? 1 : ((total / (limit <= 0 ? fallbackLimit : limit)).ceil()),
    );

    return PaginationMeta(
      page: page < 1 ? fallbackPage : page,
      limit: limit < 1 ? fallbackLimit : limit,
      total: total < 0 ? fallbackTotal : total,
      totalPages: totalPages < 1 ? 1 : totalPages,
    );
  }

  bool get hasMore => page < totalPages;
}

class PaginatedResponse<T> {
  final List<T> items;
  final PaginationMeta meta;

  const PaginatedResponse({required this.items, required this.meta});
}

PaginatedResponse<T> parsePaginatedResponseEnvelope<T>(
  dynamic envelope, {
  required T Function(Map<String, dynamic> json) itemFromJson,
  int fallbackPage = 1,
  int fallbackLimit = 20,
}) {
  if (envelope is! Map) {
    return PaginatedResponse(
      items: const [],
      meta: PaginationMeta.fromJson(
        null,
        fallbackPage: fallbackPage,
        fallbackLimit: fallbackLimit,
      ),
    );
  }

  final map = Map<String, dynamic>.from(envelope);
  final data = map['data'];
  final items = data is List
      ? data
            .whereType<Map>()
            .map((item) => itemFromJson(Map<String, dynamic>.from(item)))
            .toList(growable: false)
      : <T>[];

  return PaginatedResponse(
    items: items,
    meta: PaginationMeta.fromJson(
      map['meta'],
      fallbackPage: fallbackPage,
      fallbackLimit: fallbackLimit,
      fallbackTotal: items.length,
    ),
  );
}

class PaginatedState<T> {
  final List<T> items;
  final PaginationMeta meta;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool hasLoaded;

  const PaginatedState({
    required this.items,
    required this.meta,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.isRefreshing,
    required this.hasLoaded,
  });

  factory PaginatedState.initial({int limit = 20}) {
    return PaginatedState<T>(
      items: const [],
      meta: PaginationMeta.initial(limit: limit),
      isInitialLoading: false,
      isLoadingMore: false,
      isRefreshing: false,
      hasLoaded: false,
    );
  }

  bool get hasMore => meta.hasMore;

  PaginatedState<T> copyWith({
    List<T>? items,
    PaginationMeta? meta,
    bool? isInitialLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? hasLoaded,
  }) {
    return PaginatedState<T>(
      items: items ?? this.items,
      meta: meta ?? this.meta,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}
