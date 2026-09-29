/// A real news article parsed from a public RSS/Atom feed.
class NewsItem {
  const NewsItem({
    required this.id,
    required this.title,
    required this.source,
    required this.summary,
    required this.publishedAt,
    required this.category,
    required this.articleUrl,
    this.imageUrl,
    this.tags = const [],
  });

  final String id;
  final String title;

  /// Real publisher name (e.g. "IEEE Spectrum", "Reuters").
  final String source;
  final String summary;
  final DateTime publishedAt;
  final NewsCategory category;

  /// The item's own article URL from the feed (never a homepage).
  final String articleUrl;
  final String? imageUrl;
  final List<String> tags;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'source': source,
        'summary': summary,
        'publishedAt': publishedAt.toUtc().toIso8601String(),
        'category': category.name,
        'articleUrl': articleUrl,
        'imageUrl': imageUrl,
        'tags': tags,
      };

  factory NewsItem.fromJson(Map<String, dynamic> j) => NewsItem(
        id: j['id'] as String,
        title: j['title'] as String,
        source: j['source'] as String,
        summary: (j['summary'] as String?) ?? '',
        publishedAt: DateTime.parse(j['publishedAt'] as String),
        category: NewsCategory.values.byName(j['category'] as String),
        articleUrl: j['articleUrl'] as String,
        imageUrl: j['imageUrl'] as String?,
        tags: ((j['tags'] as List?) ?? const []).cast<String>(),
      );
}

enum NewsCategory {
  elon,
  robotics,
  space,
}
