import 'dart:math' as math;
import '../models/extracted_resource.dart';

/// Restores chronological `1..N` ordering when a single YouTube creator's
/// playlist was uploaded/arranged newest-first (`N..1`), while preserving
/// exact original order for custom multi-author playlists and all other cases.
class PlaylistOrderNormalizer {
  PlaylistOrderNormalizer._();

  static final RegExp _keywordEpisodeRegex = RegExp(
    r'(?:^|[\s|:\-\[\(#])(?:lecture|lec|lesson|episode|ep|part|chapter|ch|module|mod|unit|session|video|vid|tutorial|tut|class|week|day)\s*[#:\-.]?\s*(\d{1,4})\b(?!\.\d)',
    caseSensitive: false,
  );

  static final RegExp _hashEpisodeRegex = RegExp(
    r'(?:^|[\s|:\-\[\(])#\s*(\d{1,4})\b(?!\.\d)',
  );

  static final RegExp _leadingNumberRegex = RegExp(
    r'^\s*[\[\(]?(\d{1,4})[\]\)]?\s*(?:[.\-:|)\]]\s+|\s+-\s+)',
  );

  static final RegExp _trailingNumberRegex = RegExp(
    r'(?:[\|\-]\s*|\[\s*|\(\s*)(\d{1,4})(?:\s*[\]\)]|\s*$)',
  );

  /// Returns a normalized list of playlist items.
  ///
  /// Reverses [items] (and re-indexes `0..N-1`) **only** when:
  /// 1. The playlist is from a single dominant channel/author (rejects
  ///    multi-author custom playlists and playlists missing author metadata).
  /// 2. Titles carry explicit episode/sequence numbers that are overwhelmingly
  ///    in descending order (`N, N-1, ..., 1`).
  static List<RawResourceItem> normalize(List<RawResourceItem> items) {
    if (items.length < 2) return items;

    // Gate 1: Single-author verification
    if (!_isSingleAuthorPlaylist(items)) {
      return items;
    }

    // Gate 2: Descending sequence verification
    if (!_isPredominantlyDescending(items)) {
      return items;
    }

    final reversed = items.reversed.toList();
    return List<RawResourceItem>.generate(
      reversed.length,
      (i) => reversed[i].copyWith(index: i),
      growable: false,
    );
  }

  static bool _isSingleAuthorPlaylist(List<RawResourceItem> items) {
    final authorCounts = <String, int>{};
    int knownCount = 0;

    for (final item in items) {
      final raw = item.author?.trim().toLowerCase() ?? '';
      if (raw.isEmpty) continue;
      knownCount++;
      authorCounts[raw] = (authorCounts[raw] ?? 0) + 1;
    }

    final minRequiredKnown = math.max(2, (items.length * 0.70).ceil());
    if (knownCount < minRequiredKnown || authorCounts.isEmpty) {
      return false;
    }

    int topCount = 0;
    for (final count in authorCounts.values) {
      if (count > topCount) topCount = count;
    }

    return (topCount / knownCount) >= 0.90;
  }

  static bool _isPredominantlyDescending(List<RawResourceItem> items) {
    final numbers = <int>[];
    for (final item in items) {
      final n = extractSequenceNumber(item.title);
      if (n != null) {
        numbers.add(n);
      }
    }

    final minRequiredNumbered =
        items.length >= 4 ? math.max(3, (items.length * 0.60).ceil()) : 2;
    if (numbers.length < minRequiredNumbered) {
      return false;
    }

    if (numbers.first <= numbers.last) {
      return false;
    }

    int descendingPairs = 0;
    int ascendingPairs = 0;
    for (int i = 0; i < numbers.length - 1; i++) {
      if (numbers[i] > numbers[i + 1]) {
        descendingPairs++;
      } else if (numbers[i] < numbers[i + 1]) {
        ascendingPairs++;
      }
    }

    final comparablePairs = descendingPairs + ascendingPairs;
    if (comparablePairs == 0) return false;
    if (ascendingPairs == 0) return descendingPairs >= 1;

    return descendingPairs > ascendingPairs &&
        (descendingPairs / comparablePairs) >= 0.85;
  }

  /// Extracts an explicit episode/lesson number from [title], returning `null`
  /// for unnumbered titles or likely years/version numbers.
  static int? extractSequenceNumber(String title) {
    final keywordMatch = _keywordEpisodeRegex.firstMatch(title);
    if (keywordMatch != null) {
      final n = int.tryParse(keywordMatch.group(1) ?? '');
      if (_isValidEpisodeNumber(n, allowYearLike: false)) return n;
    }

    final hashMatch = _hashEpisodeRegex.firstMatch(title);
    if (hashMatch != null) {
      final n = int.tryParse(hashMatch.group(1) ?? '');
      if (_isValidEpisodeNumber(n, allowYearLike: false)) return n;
    }

    final leadingMatch = _leadingNumberRegex.firstMatch(title);
    if (leadingMatch != null) {
      final n = int.tryParse(leadingMatch.group(1) ?? '');
      if (_isValidEpisodeNumber(n, allowYearLike: false)) return n;
    }

    final trailingMatch = _trailingNumberRegex.firstMatch(title);
    if (trailingMatch != null) {
      final n = int.tryParse(trailingMatch.group(1) ?? '');
      if (_isValidEpisodeNumber(n, allowYearLike: false)) return n;
    }

    return null;
  }

  static bool _isValidEpisodeNumber(int? n, {required bool allowYearLike}) {
    if (n == null || n < 0) return false;
    if (!allowYearLike && n >= 1900 && n <= 2099) return false;
    return true;
  }
}

