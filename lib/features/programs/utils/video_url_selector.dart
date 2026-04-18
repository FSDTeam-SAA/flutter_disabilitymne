String selectPreferredVideoUrl({String? demoVideo, List<String>? demoVideos}) {
  final candidates = <String>[
    ...[demoVideo].whereType<String>(),
    ...?demoVideos,
  ].map((url) => url.trim()).where((url) => url.isNotEmpty).toSet().toList();

  if (candidates.isEmpty) {
    return '';
  }

  var selected = candidates.first;
  var bestScore = _scoreVideoCandidate(selected);

  for (final candidate in candidates.skip(1)) {
    final score = _scoreVideoCandidate(candidate);
    if (score > bestScore) {
      selected = candidate;
      bestScore = score;
    }
  }

  return selected;
}

int _scoreVideoCandidate(String url) {
  final lower = url.toLowerCase();
  var score = 0;

  for (final marker in _highQualityMarkers) {
    if (lower.contains(marker)) {
      score += 400;
    }
  }

  for (final marker in _lowQualityMarkers) {
    if (lower.contains(marker)) {
      score -= 500;
    }
  }

  final pMatches = RegExp(r'(\d{3,4})p').allMatches(lower);
  for (final match in pMatches) {
    final value = int.tryParse(match.group(1) ?? '');
    if (value != null) {
      score += value;
    }
  }

  final dimensionMatches = RegExp(r'(\d{3,4})x(\d{3,4})').allMatches(lower);
  for (final match in dimensionMatches) {
    final width = int.tryParse(match.group(1) ?? '');
    final height = int.tryParse(match.group(2) ?? '');
    if (width != null && height != null) {
      score += width > height ? width : height;
    }
  }

  final uploadSegment = _extractUploadSegment(lower);
  if (uploadSegment != null) {
    if (uploadSegment.startsWith('v')) {
      score += 300;
    } else {
      final qualityMatch = RegExp(r'q_(\d{1,3})').firstMatch(uploadSegment);
      final qualityValue = int.tryParse(qualityMatch?.group(1) ?? '');
      if (qualityValue != null && qualityValue < 70) {
        score -= (70 - qualityValue) * 10;
      }

      final widthMatch = RegExp(r'w_(\d{2,4})').firstMatch(uploadSegment);
      final widthValue = int.tryParse(widthMatch?.group(1) ?? '');
      if (widthValue != null) {
        score += widthValue >= 1080 ? 250 : -250;
      }

      final heightMatch = RegExp(r'h_(\d{2,4})').firstMatch(uploadSegment);
      final heightValue = int.tryParse(heightMatch?.group(1) ?? '');
      if (heightValue != null) {
        score += heightValue >= 720 ? 150 : -150;
      }
    }
  }

  return score;
}

String? _extractUploadSegment(String url) {
  final uploadMarker = '/upload/';
  final uploadStart = url.indexOf(uploadMarker);
  if (uploadStart == -1) {
    return null;
  }

  final segmentStart = uploadStart + uploadMarker.length;
  final segmentEnd = url.indexOf('/', segmentStart);
  if (segmentEnd == -1) {
    return null;
  }

  return url.substring(segmentStart, segmentEnd);
}

const _highQualityMarkers = <String>[
  'original',
  'source',
  'master',
  '1080p',
  '1440p',
  '2160p',
  '4k',
  'uhd',
];

const _lowQualityMarkers = <String>[
  'thumbnail',
  'thumb',
  'preview',
  'poster',
  'small',
  'low',
  'compressed',
  'q_auto:low',
  'q_10',
  'q_20',
  'q_30',
  'q_40',
  'q_50',
  '360p',
  '480p',
];
