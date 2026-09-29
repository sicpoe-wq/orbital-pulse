import 'news_item.dart';

/// A real YouTube video parsed from a public channel RSS (Atom) feed.
class VideoItem {
  const VideoItem({
    required this.videoId,
    required this.title,
    required this.channel,
    required this.channelId,
    required this.publishedAt,
    required this.category,
    required this.url,
    required this.thumbnailUrl,
    this.views,
    this.isShort = false,
    this.tags = const [],
  });

  final String videoId;
  final String title;
  final String channel;
  final String channelId;
  final DateTime publishedAt;
  final NewsCategory category;

  /// The video's own watch (or shorts) URL from the feed.
  final String url;
  final String thumbnailUrl;
  final int? views;
  final bool isShort;
  final List<String> tags;

  Map<String, dynamic> toJson() => {
        'videoId': videoId,
        'title': title,
        'channel': channel,
        'channelId': channelId,
        'publishedAt': publishedAt.toUtc().toIso8601String(),
        'category': category.name,
        'url': url,
        'thumbnailUrl': thumbnailUrl,
        'views': views,
        'isShort': isShort,
        'tags': tags,
      };

  factory VideoItem.fromJson(Map<String, dynamic> j) => VideoItem(
        videoId: j['videoId'] as String,
        title: j['title'] as String,
        channel: j['channel'] as String,
        channelId: j['channelId'] as String,
        publishedAt: DateTime.parse(j['publishedAt'] as String),
        category: NewsCategory.values.byName(j['category'] as String),
        url: j['url'] as String,
        thumbnailUrl: j['thumbnailUrl'] as String,
        views: j['views'] as int?,
        isShort: (j['isShort'] as bool?) ?? false,
        tags: ((j['tags'] as List?) ?? const []).cast<String>(),
      );
}
