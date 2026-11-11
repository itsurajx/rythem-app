enum ExtractedResourceType {
  playlist,
  singleVideoWithTimestamps,
  singleVideo,
  webDoc,
}

class RawResourceItem {
  final String title;
  final String sourceUrl;
  final int? timestampSeconds;
  final int durationSeconds;
  final int index;
  final String? description;
  final String? thumbnailUrl;
  final String? author;

  const RawResourceItem({
    required this.title,
    required this.sourceUrl,
    this.timestampSeconds,
    required this.durationSeconds,
    required this.index,
    this.description,
    this.thumbnailUrl,
    this.author,
  });

  RawResourceItem copyWith({
    String? title,
    String? sourceUrl,
    int? timestampSeconds,
    int? durationSeconds,
    int? index,
    String? description,
    String? thumbnailUrl,
    String? author,
  }) {
    return RawResourceItem(
      title: title ?? this.title,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      timestampSeconds: timestampSeconds ?? this.timestampSeconds,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      index: index ?? this.index,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      author: author ?? this.author,
    );
  }
}

class ExtractedResource {
  final String title;
  final String? description;
  final String? author;
  final String sourceUrl;
  final ExtractedResourceType resourceType;
  final List<RawResourceItem> items;

  const ExtractedResource({
    required this.title,
    this.description,
    this.author,
    required this.sourceUrl,
    required this.resourceType,
    required this.items,
  });

  int get totalDurationSeconds =>
      items.fold(0, (sum, item) => sum + item.durationSeconds);
}
