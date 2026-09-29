import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/launch_item.dart';
import '../models/news_item.dart';
import '../models/video_item.dart';

class Cached<T> {
  Cached(this.data, this.fetchedAt);
  final T data;
  final DateTime fetchedAt;
  Duration get age => DateTime.now().difference(fetchedAt);
}

/// Stores the last good results locally for offline use.
class CacheStore {
  static String _newsKey(NewsCategory c) => 'news_cache_v2_${c.name}';
  static String _videoKey(NewsCategory c) => 'video_cache_v1_${c.name}';
  static const _launchKey = 'launch_cache_v2';
  static const _launchBlockedUntilKey = 'launch_blocked_until_v2';

  static Future<Cached<List<NewsItem>>?> loadNews(NewsCategory c) async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_newsKey(c));
      if (raw == null) return null;
      final j = jsonDecode(raw) as Map<String, dynamic>;
      final items = (j['items'] as List)
          .map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
          .toList();
      return Cached(items, DateTime.parse(j['fetchedAt'] as String));
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveNews(NewsCategory c, List<NewsItem> items) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      _newsKey(c),
      jsonEncode({
        'fetchedAt': DateTime.now().toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
      }),
    );
  }

  static Future<Cached<List<LaunchItem>>?> loadLaunches() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_launchKey);
      if (raw == null) return null;
      final j = jsonDecode(raw) as Map<String, dynamic>;
      final items = (j['items'] as List)
          .map((e) => LaunchItem.fromJson(e as Map<String, dynamic>))
          .toList();
      return Cached(items, DateTime.parse(j['fetchedAt'] as String));
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveLaunches(List<LaunchItem> items) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      _launchKey,
      jsonEncode({
        'fetchedAt': DateTime.now().toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
      }),
    );
  }

  static Future<DateTime?> launchBlockedUntil() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_launchBlockedUntilKey);
    return s == null ? null : DateTime.tryParse(s);
  }

  static Future<void> setLaunchBlockedUntil(DateTime t) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_launchBlockedUntilKey, t.toIso8601String());
  }

  static Future<Cached<List<VideoItem>>?> loadVideos(NewsCategory c) async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_videoKey(c));
      if (raw == null) return null;
      final j = jsonDecode(raw) as Map<String, dynamic>;
      final items = (j['items'] as List)
          .map((e) => VideoItem.fromJson(e as Map<String, dynamic>))
          .toList();
      return Cached(items, DateTime.parse(j['fetchedAt'] as String));
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveVideos(NewsCategory c, List<VideoItem> items) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      _videoKey(c),
      jsonEncode({
        'fetchedAt': DateTime.now().toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
      }),
    );
  }
}
