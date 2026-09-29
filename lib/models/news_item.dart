/// Sample-backed news article model for OrbitalPulse feed cards.
class NewsItem {
  const NewsItem({
    required this.id,
    required this.title,
    required this.source,
    required this.summary,
    required this.publishedAt,
    required this.category,
    this.imageUrl,
    this.articleUrl,
    this.tags = const [],
  });

  final String id;
  final String title;
  final String source;
  final String summary;
  final DateTime publishedAt;
  final NewsCategory category;
  final String? imageUrl;
  final String? articleUrl;
  final List<String> tags;
}

enum NewsCategory {
  elon,
  robotics,
  space,
}
