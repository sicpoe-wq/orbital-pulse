// Run: dart run tool/verify_feeds.dart [--launches]
// Fetches every configured feed, prints item counts + sample title/link,
// and flags any link that looks like a bare homepage.
import 'dart:io';

import 'package:orbital_pulse/models/news_item.dart';
import 'package:orbital_pulse/services/launch_service.dart';
import 'package:orbital_pulse/services/news_service.dart';

bool looksLikeHomepage(String url) {
  final u = Uri.parse(url);
  return u.path.isEmpty || u.path == '/';
}

Future<void> main(List<String> args) async {
  final svc = NewsService();
  var problems = 0;
  for (final cat in NewsCategory.values) {
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
  stdout.writeln('\nproblems: $problems');
  exit(problems == 0 ? 0 : 1);
}
