import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/news_item.dart';
import 'feed_parser.dart';
import 'feed_sources.dart';

class FeedResult {
  FeedResult(this.source, this.items, [this.error]);
  final FeedSource source;
  final List<NewsItem> items;
  final Object? error;
}

class NewsFetchResult {
  NewsFetchResult(this.items, this.perFeed);
  final List<NewsItem> items;
  final List<FeedResult> perFeed;
  int get failedFeeds => perFeed.where((f) => f.error != null).length;
}

/// Fetches all feeds for a tab in parallel, merges, dedupes, sorts newest first.
/// Pure Dart so it can be exercised from `dart run tool/verify_feeds.dart`.
class NewsService {
  NewsService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _headers = {
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) '
            'Chrome/124.0 Mobile Safari/537.36 OrbitalPulse/0.2',
    'Accept': 'application/rss+xml, application/atom+xml, application/xml, text/xml, */*',
  };

  Future<FeedResult> fetchFeed(FeedSource src, NewsCategory cat) async {
    try {
      final res = await _client
          .get(Uri.parse(src.url), headers: _headers)
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) {
        return FeedResult(src, const [], 'HTTP ${res.statusCode}');
      }
      final items = FeedParser.parse(
          utf8.decode(res.bodyBytes, allowMalformed: true), src, cat);
      return FeedResult(src, items);
    } catch (e) {
      return FeedResult(src, const [], e);
    }
  }

  Future<NewsFetchResult> fetchCategory(NewsCategory cat) async {
    final sources = FeedSources.byCategory[cat] ?? const [];
    final results =
        await Future.wait(sources.map((s) => fetchFeed(s, cat)));
    final merged = mergeAndDedupe(results.expand((r) => r.items));
    return NewsFetchResult(merged, results);
  }

  static String _titleKey(String t) =>
      t.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');

  static List<NewsItem> mergeAndDedupe(Iterable<NewsItem> items) {
    final seenLinks = <String>{};
    final seenTitles = <String>{};
    final out = <NewsItem>[];
    final sorted = items.toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    final now = DateTime.now().toUtc().add(const Duration(hours: 1));
    for (final it in sorted) {
      if (it.publishedAt.isAfter(now)) continue; // bogus future dates
      final link = it.articleUrl.split('#').first.replaceAll(RegExp(r'/$'), '');
      final tk = _titleKey(it.title);
      if (seenLinks.contains(link) || seenTitles.contains(tk)) continue;
      seenLinks.add(link);
      seenTitles.add(tk);
      out.add(it);
    }
    return out.take(80).toList();
  }

  void close() => _client.close();
}
