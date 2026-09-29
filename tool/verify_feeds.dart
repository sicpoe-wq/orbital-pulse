// Run: dart run tool/verify_feeds.dart [--launches] [--videos | --videos-only]
// Fetches every configured feed, prints item counts + sample title/link,
// and flags any link that looks like a bare homepage.
import 'dart:io';

import 'package:orbital_pulse/models/news_item.dart';
import 'package:orbital_pulse/services/launch_service.dart';
import 'package:orbital_pulse/services/news_service.dart';
import 'package:orbital_pulse/services/video_service.dart';

bool looksLikeHomepage(String url) {
  final u = Uri.parse(url);
  return u.path.isEmpty || u.path == '/';
}

Future<void> main(List<String> args) async {
  var problems = 0;
  final videosOnly = args.contains('--videos-only');
  final svc = NewsService();
  for (final cat in videosOnly ? const <NewsCategory>[] : NewsCategory.values) {
    final r = await svc.fetchCategory(cat);
    stdout.writeln('\n=== ${cat.name.toUpperCase()} — ${r.items.length} merged items ===');
    for (final f in r.perFeed) {
      final s = f.items.isEmpty ? null : f.items.first;
      stdout.writeln('  [${f.items.length.toString().padLeft(2)}] ${f.source.name}'
          '${f.source.tag != null ? ' (${f.source.tag})' : ''}'
          '${f.error != null ? '  ERROR: ${f.error}' : ''}');
      if (s != null) {
        stdout.writeln('       "${s.title}" — ${s.source}, ${s.publishedAt.toIso8601String()}');
        stdout.writeln('       ${s.articleUrl}${s.imageUrl != null ? '  [img]' : ''}');
      }
      if (f.items.isEmpty) problems++;
    }
    final homes = r.items.where((i) => looksLikeHomepage(i.articleUrl)).toList();
    stdout.writeln('  homepage-like links: ${homes.length}');
    problems += homes.length;
    final withImg = r.items.where((i) => i.imageUrl != null).length;
    stdout.writeln('  items with thumbnail: $withImg/${r.items.length}');
  }
  svc.close();

  if (args.contains('--launches')) {
    final ls = LaunchService();
    try {
      final launches = await ls.fetchUpcoming();
      stdout.writeln('\n=== LAUNCHES — ${launches.length} ===');
      for (final l in launches.take(5)) {
        stdout.writeln('  ${l.net.toLocal()} | ${l.company} | ${l.vehicle} | ${l.missionName} | ${l.statusAbbrev} | orbit=${l.orbit} | pad=${l.pad} | stream=${l.streamUrl}');
      }
      final providers = launches.map((l) => l.company).toSet();
      stdout.writeln('  providers: $providers');
      stdout.writeln('  with stream: ${launches.where((l) => l.hasStream).length}');
    } catch (e) {
      stdout.writeln('LAUNCHES ERROR: $e');
      problems++;
    } finally {
      ls.close();
    }
  }
  if (videosOnly || args.contains('--videos')) {
    problems += await verifyVideos();
  }
  stdout.writeln('\nproblems: $problems');
  exit(problems == 0 ? 0 : 1);
}

final _watchRe =
    RegExp(r'^https://www\.youtube\.com/(watch\?v=|shorts/)[A-Za-z0-9_-]{11}$');

/// Every channel must return entries (before keyword filtering), and every
/// merged video must have a real watch URL + i.ytimg thumbnail.
Future<int> verifyVideos() async {
  final vs = VideoService();
  var problems = 0;
  for (final cat in NewsCategory.values) {
    final r = await vs.fetchCategory(cat);
    stdout.writeln('\n=== VIDEOS ${cat.name.toUpperCase()} — ${r.items.length} merged ===');
    for (final c in r.perChannel) {
      stdout.writeln('  [${c.items.length.toString().padLeft(2)}] ${c.channel.name} (${c.channel.channelId})'
          '${c.channel.keywords != null ? ' [filtered]' : ''}'
          '${c.error != null ? '  ERROR: ${c.error}' : ''}');
      if (c.error != null) problems++;
      // Filtered channels may legitimately have 0 matches; unfiltered must not.
      if (c.error == null && c.items.isEmpty && c.channel.keywords == null) {
        stdout.writeln('       NO ENTRIES');
        problems++;
      }
    }
    for (final v in r.items.take(4)) {
      stdout.writeln('   • "${v.title}" — ${v.channel}, ${v.publishedAt.toIso8601String()}'
          '${v.views != null ? ', ${v.views} views' : ''}');
      stdout.writeln('     ${v.url}');
    }
    final badUrl = r.items.where((v) => !_watchRe.hasMatch(v.url)).length;
    final badThumb =
        r.items.where((v) => !Uri.parse(v.thumbnailUrl).host.endsWith('ytimg.com')).length;
    final ids = r.items.map((v) => v.videoId).toSet().length;
    var sorted = true;
    for (var i = 1; i < r.items.length; i++) {
      if (r.items[i].publishedAt.isAfter(r.items[i - 1].publishedAt)) sorted = false;
    }
    stdout.writeln('  bad urls: $badUrl, bad thumbs: $badThumb, dupes: ${r.items.length - ids}, sorted: $sorted');
    if (r.items.isEmpty) problems++;
    problems += badUrl + badThumb + (r.items.length - ids) + (sorted ? 0 : 1);
  }
  vs.close();
  return problems;
}
