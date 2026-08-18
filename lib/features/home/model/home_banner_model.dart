class HomeBannerModel {
  final String id;
  final String imageUrl;
  final int sortOrder;
  final bool isActive;

  const HomeBannerModel({
    required this.id,
    required this.imageUrl,
    required this.sortOrder,
    required this.isActive,
  });

  factory HomeBannerModel.fromJson(Map<String, dynamic> json) {
    return HomeBannerModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      imageUrl: _readImageUrl(json),
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  static String _readImageUrl(Map<String, dynamic> json) {
    final direct = json['imageUrl']?.toString().trim() ?? '';
    if (direct.isNotEmpty) return direct;

    final nested = json['image'];
    if (nested is Map) {
      final nestedUrl =
          (nested['url'] ?? nested['path'] ?? nested['secure_url'])
              ?.toString()
              .trim() ??
          '';
      if (nestedUrl.isNotEmpty) return nestedUrl;
    }

    return json['url']?.toString().trim() ?? '';
  }

  bool get hasImage => imageUrl.trim().isNotEmpty;
}
