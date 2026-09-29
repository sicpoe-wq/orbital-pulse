import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/news_item.dart';
import '../models/video_item.dart';
import 'video_parser.dart';
import 'video_sources.dart';

class ChannelResult {
  ChannelResult(this.channel, this.items, [this.error]);
  final VideoChannel channel;
  final List<VideoItem> items;
  final Object? error;
}

class VideoFetchResult {
  VideoFetchResult(this.items, this.perChannel);
  final List<VideoItem> items;
  final List<ChannelResult> perChannel;
  int get failedChannels => perChannel.where((c) => c.error != null).length;
}

/// Fetches all YouTube channel feeds for a category in parallel, merges,
/// dedupes by video id, and sorts newest first. Pure Dart.
class VideoService {
  VideoService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _headers = {
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) '
            'Chrome/124.0 Mobile Safari/537.36 OrbitalPulse/0.3',
    'Accept': 'application/atom+xml, application/xml, text/xml, */*',
  };

  Future<ChannelResult> fetchChannel(VideoChannel ch, NewsCategory cat) async {
    try {
      final res = await _client
          .get(Uri.parse(ch.feedUrl), headers: _headers)
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) {
        return ChannelResult(ch, const [], 'HTTP ${res.statusCode}');
      }
      final items = VideoParser.parse(
          utf8.decode(res.bodyBytes, allowMalformed: true), ch, cat);
      return ChannelResult(ch, items);
    } catch (e) {
      return ChannelResult(ch, const [], e);
    }
  }

  Future<VideoFetchResult> fetchCategory(NewsCategory cat) async {
    final channels = VideoSources.byCategory[cat] ?? const [];
    final results =
        await Future.wait(channels.map((c) => fetchChannel(c, cat)));
    return VideoFetchResult(
        mergeAndDedupe(results.expand((r) => r.items)), results);
  }

  static List<VideoItem> mergeAndDedupe(Iterable<VideoItem> items,
      {int limit = 60}) {
    final byId = <String, VideoItem>{};
    for (final v in items) {
      final prev = byId[v.videoId];
      if (prev == null) {
        byId[v.videoId] = v;
      } else if (v.tags.any((t) => !prev.tags.contains(t))) {
        // Same video from two configured channels: keep one, union the tags.
        byId[v.videoId] = VideoItem(
          videoId: prev.videoId,
          title: prev.title,
          channel: prev.channel,
          channelId: prev.channelId,
          publishedAt: prev.publishedAt,
          category: prev.category,
          url: prev.url,
          thumbnailUrl: prev.thumbnailUrl,
          views: prev.views ?? v.views,
          isShort: prev.isShort,
          tags: {...prev.tags, ...v.tags}.toList(),
        );
      }
    }
    final out = byId.values.toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return out.take(limit).toList();
  }

  void close() => _client.close();
}
