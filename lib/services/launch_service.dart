import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/launch_item.dart';

class LaunchApiException implements Exception {
  LaunchApiException(this.message, {this.retryAfter});
  final String message;
  final Duration? retryAfter;
  @override
  String toString() => message;
}

/// The Space Devs Launch Library 2 (free tier ≈15 requests/hour/IP).
/// Pure Dart; caching is handled by [CacheStore] in the UI layer.
class LaunchService {
  LaunchService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  static const endpoint =
      'https://ll.thespacedevs.com/2.3.0/launches/upcoming/?limit=40&mode=detailed&hide_recent_previous=true';

  Future<List<LaunchItem>> fetchUpcoming() async {
    final res = await _client.get(Uri.parse(endpoint), headers: const {
      'Accept': 'application/json',
      'User-Agent': 'OrbitalPulse/0.2 (Android; github.com/sicpoe-wq/orbital-pulse)',
    }).timeout(const Duration(seconds: 20));
    if (res.statusCode == 429) {
      final ra = int.tryParse(res.headers['retry-after'] ?? '');
      throw LaunchApiException(
        'Launch Library rate limit reached'
        '${ra != null ? ' — try again in ${(ra / 60).ceil()} min' : ''}.',
        retryAfter: ra != null ? Duration(seconds: ra) : null,
      );
    }
    if (res.statusCode != 200) {
      throw LaunchApiException('Launch Library returned HTTP ${res.statusCode}');
    }
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final results = (data['results'] as List? ?? const [])
        .whereType<Map<String, dynamic>>();
    final out = <LaunchItem>[];
    for (final r in results) {
      final l = parseLaunch(r);
      if (l != null) out.add(l);
    }
    out.sort((a, b) => a.net.compareTo(b.net));
    return out;
  }

  static String? _s(Object? v) =>
      v is String && v.trim().isNotEmpty ? v.trim() : null;

  static Map<String, dynamic>? _m(Object? v) =>
      v is Map<String, dynamic> ? v : null;

  static LaunchItem? parseLaunch(Map<String, dynamic> r) {
    final net = DateTime.tryParse(_s(r['net']) ?? '');
    if (net == null) return null;
    final lsp = _m(r['launch_service_provider']);
    final rocketCfg = _m(_m(r['rocket'])?['configuration']);
    final mission = _m(r['mission']);
    final pad = _m(r['pad']);
    final status = _m(r['status']);
    final name = _s(r['name']) ?? 'Unknown launch';

    // Webcasts: 2.3.0 uses `vid_urls`, 2.2.0 uses `vidURLs`.
    final vids = ((r['vid_urls'] ?? r['vidURLs']) as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList()
      ..sort((a, b) => ((a['priority'] as num?) ?? 99)
          .compareTo((b['priority'] as num?) ?? 99));
    final stream = vids.map((v) => _s(v['url'])).whereType<String>().firstOrNull;

    final infos = ((r['info_urls'] ?? r['infoURLs']) as List? ?? const [])
        .whereType<Map<String, dynamic>>();
    final info = infos.map((v) => _s(v['url'])).whereType<String>().firstOrNull;

    final img = r['image'];
    final imageUrl = img is String ? _s(img) : _s(_m(img)?['image_url']);

    final padName = _s(pad?['name']);
    final location = _s(_m(pad?['location'])?['name']);
    final padText = [padName, location].whereType<String>().join(', ');

    final missionName = _s(mission?['name']);
    final desc = _s(mission?['description']);

    return LaunchItem(
      id: _s(r['id']) ?? name,
      missionName: missionName ?? name,
      company: _s(lsp?['name']) ?? 'Unknown provider',
      vehicle: _s(rocketCfg?['full_name']) ?? _s(rocketCfg?['name']) ?? name.split('|').first.trim(),
      net: net.toUtc(),
      windowStart: DateTime.tryParse(_s(r['window_start']) ?? '')?.toUtc(),
      windowEnd: DateTime.tryParse(_s(r['window_end']) ?? '')?.toUtc(),
      pad: padText.isEmpty ? 'Pad TBD' : padText,
      payloadSummary: desc ?? 'No mission description published yet.',
      statusName: _s(status?['name']) ?? 'Unknown',
      statusAbbrev: _s(status?['abbrev']) ?? 'TBD',
      streamUrl: stream,
      orbit: _orbit(_s(_m(mission?['orbit'])?['name'])),
      missionType: _s(mission?['type']),
      imageUrl: imageUrl,
      infoUrl: info,
    );
  }

  static String? _orbit(String? o) =>
      o == null || o.toLowerCase() == 'unknown' ? null : o;

  void close() => _client.close();
}
