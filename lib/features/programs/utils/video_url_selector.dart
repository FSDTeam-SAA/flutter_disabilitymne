String selectPreferredVideoUrl({String? demoVideo, List<String>? demoVideos}) {
  final normalizedVideos = (demoVideos ?? [])
      .map((url) => url.trim())
      .where((url) => url.isNotEmpty)
      .toList();

  // Prefer the newest upload (last entry in demoVideos).
  if (normalizedVideos.isNotEmpty) {
    return normalizedVideos.last;
  }

  final primary = demoVideo?.trim() ?? '';
  if (primary.isNotEmpty) {
    return primary;
  }

  return '';
}
