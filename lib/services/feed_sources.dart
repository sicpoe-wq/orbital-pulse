import '../models/news_item.dart';

/// A public RSS/Atom feed used to populate a news tab.
class FeedSource {
  const FeedSource({
    required this.name,
    required this.url,
    this.tag,
    this.maxItems = 25,
    this.isGoogleNews = false,
  });

  /// Display name used when the feed item has no own source attribution.
  final String name;
  final String url;

  /// Optional tag applied to every item (e.g. "SpaceX" for a SpaceX query).
  final String? tag;
  final int maxItems;

  /// Google News items carry the real publisher in `<source>`, and their
  /// links are per-article news.google.com redirect URLs.
  final bool isGoogleNews;
}

String _gn(String query) =>
    'https://news.google.com/rss/search?q=${Uri.encodeQueryComponent(query)}'
    '&hl=en-US&gl=US&ceid=US:en';

/// All feeds were verified with curl to return items (Sep 2026).
class FeedSources {

  static final Map<NewsCategory, List<FeedSource>> byCategory = {
    NewsCategory.elon: [
      FeedSource(name: 'Google News', url: _gn('SpaceX when:7d'), tag: 'SpaceX', maxItems: 12, isGoogleNews: true),
      FeedSource(name: 'Google News', url: _gn('Tesla when:7d'), tag: 'Tesla', maxItems: 12, isGoogleNews: true),
      FeedSource(name: 'Google News', url: _gn('xAI Grok when:7d'), tag: 'xAI', maxItems: 10, isGoogleNews: true),
      FeedSource(name: 'Google News', url: _gn('Neuralink when:30d'), tag: 'Neuralink', maxItems: 8, isGoogleNews: true),
      FeedSource(name: 'Google News', url: _gn('Starlink when:7d'), tag: 'Starlink', maxItems: 8, isGoogleNews: true),
      FeedSource(name: 'Google News', url: _gn('"Boring Company" when:30d'), tag: 'Boring Co', maxItems: 6, isGoogleNews: true),
      const FeedSource(name: 'Teslarati', url: 'https://www.teslarati.com/feed/'),
      const FeedSource(name: 'Electrek', url: 'https://electrek.co/guides/tesla/feed/', tag: 'Tesla', maxItems: 15),
    ],
    NewsCategory.robotics: [
      const FeedSource(name: 'IEEE Spectrum', url: 'https://spectrum.ieee.org/feeds/topic/robotics.rss'),
      const FeedSource(name: 'The Robot Report', url: 'https://www.therobotreport.com/feed/'),
      FeedSource(name: 'Google News', url: _gn('robotics OR "humanoid robot" when:7d'), maxItems: 20, isGoogleNews: true),
    ],
    NewsCategory.space: [
      const FeedSource(name: 'SpaceNews', url: 'https://spacenews.com/feed/'),
      const FeedSource(name: 'NASA', url: 'https://www.nasa.gov/news-release/feed/', tag: 'NASA'),
      const FeedSource(name: 'Spaceflight Now', url: 'https://spaceflightnow.com/feed/'),
      const FeedSource(name: 'NASASpaceflight', url: 'https://www.nasaspaceflight.com/feed/'),
      FeedSource(name: 'Space.com', url: _gn('site:space.com when:7d'), maxItems: 15, isGoogleNews: true),
    ],
  };

}
