import 'package:xml/xml.dart';

import '../models/news_item.dart';
import 'feed_sources.dart';

/// Parses RSS 2.0 and Atom documents into [NewsItem]s. Pure Dart (no Flutter).
class FeedParser {
  static List<NewsItem> parse(
    String body,
    FeedSource source,
    NewsCategory category,
  ) {
    final doc = XmlDocument.parse(body);
    final root = doc.rootElement;
    final isAtom = root.name.local == 'feed';
    final entries = isAtom
        ? root.findElements('entry', namespace: '*')
        : root.findAllElements('item', namespace: '*');

    final out = <NewsItem>[];
    for (final e in entries) {
      final item = isAtom
          ? _atom(e, source, category)
          : _rss(e, source, category);
      if (item != null) out.add(item);
      if (out.length >= source.maxItems) break;
    }
    return out;
  }

  static String? _text(XmlElement e, String local) {
    for (final c in e.childElements) {
      if (c.name.local == local) {
        final t = c.innerText.trim();
        if (t.isNotEmpty) return t;
      }
    }
    return null;
  }

  static NewsItem? _rss(XmlElement e, FeedSource src, NewsCategory cat) {
    var title = _text(e, 'title');
    var link = _text(e, 'link');
    if (link == null) {
      final guid = e.childElements
          .where((c) => c.name.local == 'guid')
          .firstOrNull;
      final g = guid?.innerText.trim();
      if (g != null && g.startsWith('http')) link = g;
    }
    if (title == null || link == null || !_isHttp(link)) return null;

    var source = src.name;
    if (src.isGoogleNews) {
      final s = _text(e, 'source');
      if (s != null) {
        // Site-scoped queries (e.g. site:space.com) keep the configured name.
        source = src.name == 'Google News' ? s : src.name;
        final suffix = ' - $s';
        if (title.endsWith(suffix)) {
          title = title.substring(0, title.length - suffix.length).trim();
        }
      }
    }

    final date = parseDate(_text(e, 'pubDate') ??
            _text(e, 'date') ??
            _text(e, 'published') ??
            _text(e, 'updated')) ??
        DateTime.now().toUtc();

    final rawDesc = _text(e, 'description') ?? _text(e, 'encoded') ?? '';
    final encoded = _text(e, 'encoded') ?? '';
    var summary = src.isGoogleNews ? '' : stripHtml(rawDesc);
    if (_norm(summary).startsWith(_norm(title))) summary = '';
    if (summary.length > 400) summary = '${summary.substring(0, 397)}…';

    final image = _mediaImage(e) ?? _firstImg(rawDesc) ?? _firstImg(encoded);

    return _build(src, cat, title, link, source, summary, date, image);
  }

  static NewsItem? _atom(XmlElement e, FeedSource src, NewsCategory cat) {
    final title = _text(e, 'title');
    String? link;
    for (final l in e.childElements.where((c) => c.name.local == 'link')) {
      final rel = l.getAttribute('rel') ?? 'alternate';
      if (rel == 'alternate') {
        link = l.getAttribute('href');
        break;
      }
    }
    if (title == null || link == null || !_isHttp(link)) return null;
    final date = parseDate(_text(e, 'published') ?? _text(e, 'updated')) ??
        DateTime.now().toUtc();
    final rawDesc = _text(e, 'summary') ?? _text(e, 'content') ?? '';
    var summary = stripHtml(rawDesc);
    if (summary.length > 400) summary = '${summary.substring(0, 397)}…';
    final image = _mediaImage(e) ?? _firstImg(rawDesc);
    return _build(src, cat, title, link, src.name, summary, date, image);
  }

  static NewsItem _build(FeedSource src, NewsCategory cat, String title,
      String link, String source, String summary, DateTime date, String? image) {
    final cleanTitle = stripHtml(title);
    final tags = <String>{
      if (src.tag != null) src.tag!,
      ...autoTags(cat, '$cleanTitle $summary'),
    }.take(3).toList();
    return NewsItem(
      id: link,
      title: cleanTitle,
      source: source,
      summary: summary,
      publishedAt: date.toUtc(),
      category: cat,
      articleUrl: link.trim(),
      imageUrl: image,
      tags: tags,
    );
  }

  static const _elonTags = {
    'SpaceX': ['spacex', 'falcon', 'starship', 'dragon'],
    'Tesla': ['tesla', 'cybertruck', 'model y', 'model 3', 'robotaxi', 'fsd', 'optimus'],
    'xAI': ['xai', 'grok'],
    'Neuralink': ['neuralink'],
    'Starlink': ['starlink'],
    'Boring Co': ['boring company'],
  };

  static Iterable<String> autoTags(NewsCategory cat, String text) sync* {
    if (cat != NewsCategory.elon) return;
    final t = text.toLowerCase();
    for (final entry in _elonTags.entries) {
      if (entry.value.any((k) => RegExp('\\b${RegExp.escape(k)}\\b').hasMatch(t))) {
        yield entry.key;
      }
    }
  }

  static bool _isHttp(String s) =>
      s.startsWith('https://') || s.startsWith('http://');

  static String _norm(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');

  static String? _mediaImage(XmlElement e) {
    for (final c in e.childElements) {
      final n = c.name.local;
      if (n == 'thumbnail' || (n == 'content' && c.getAttribute('url') != null)) {
        final url = c.getAttribute('url');
        final medium = c.getAttribute('medium') ?? c.getAttribute('type') ?? 'image';
        if (url != null && _isHttp(url) && (medium.contains('image') || n == 'thumbnail')) {
          return url;
        }
      }
      if (n == 'group') {
        final inner = _mediaImage(c);
        if (inner != null) return inner;
      }
      if (n == 'enclosure') {
        final type = c.getAttribute('type') ?? '';
        final url = c.getAttribute('url');
        if (url != null && type.startsWith('image')) return url;
      }
    }
    return null;
  }

  static final _imgRe =
      RegExp(r'''<img[^>]+src=["']([^"']+)["']''', caseSensitive: false);

  static String? _firstImg(String html) {
    final m = _imgRe.firstMatch(html);
    final url = m?.group(1)?.replaceAll('&amp;', '&');
    if (url == null || !_isHttp(url)) return null;
    // Skip tracking pixels / emoji.
    if (url.contains('feedburner') || url.contains('/emoji/')) return null;
    return url;
  }

  static String stripHtml(String html) {
    var s = html
        .replaceAll(RegExp(r'<script[\s\S]*?</script>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'<style[\s\S]*?</style>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'<[^>]+>'), ' ');
    s = decodeEntities(s);
    s = s.replaceAll(RegExp(r'The post .* appeared first on .*\.?$'), '');
    return s.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static const _named = {
    'amp': '&', 'lt': '<', 'gt': '>', 'quot': '"', 'apos': "'", 'nbsp': ' ',
    'hellip': '…', 'mdash': '—', 'ndash': '–', 'rsquo': '’', 'lsquo': '‘',
    'rdquo': '”', 'ldquo': '“', 'eacute': 'é',
  };

  static String decodeEntities(String s) {
    return s.replaceAllMapped(RegExp(r'&(#x[0-9a-fA-F]+|#\d+|[a-zA-Z]+);'), (m) {
      final g = m.group(1)!;
      if (g.startsWith('#x')) {
        return String.fromCharCode(int.tryParse(g.substring(2), radix: 16) ?? 32);
      }
      if (g.startsWith('#')) {
        return String.fromCharCode(int.tryParse(g.substring(1)) ?? 32);
      }
      return _named[g] ?? m.group(0)!;
    });
  }

  static const _months = {
    'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
    'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
  };
  static const _zones = {
    'GMT': 0, 'UT': 0, 'UTC': 0, 'Z': 0, 'EST': -5, 'EDT': -4, 'CST': -6,
    'CDT': -5, 'MST': -7, 'MDT': -6, 'PST': -8, 'PDT': -7,
  };

  /// Parses RFC 822/1123 (RSS) and ISO 8601 (Atom) dates to UTC.
  static DateTime? parseDate(String? raw) {
    if (raw == null) return null;
    final s = raw.trim();
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso.toUtc();
    final m = RegExp(
      r'(\d{1,2})\s+([A-Za-z]{3})[a-z]*\s+(\d{2,4})\s+(\d{1,2}):(\d{2})(?::(\d{2}))?\s*([+-]\d{4}|[A-Za-z]+)?',
    ).firstMatch(s);
    if (m == null) return null;
    final month = _months[m.group(2)!.toLowerCase()];
    if (month == null) return null;
    var year = int.parse(m.group(3)!);
    if (year < 100) year += 2000;
    var dt = DateTime.utc(year, month, int.parse(m.group(1)!),
        int.parse(m.group(4)!), int.parse(m.group(5)!),
        int.tryParse(m.group(6) ?? '0') ?? 0);
    final z = m.group(7);
    if (z != null) {
      if (z.startsWith('+') || z.startsWith('-')) {
        final sign = z.startsWith('-') ? -1 : 1;
        final h = int.parse(z.substring(1, 3));
        final mi = int.parse(z.substring(3, 5));
        dt = dt.subtract(Duration(minutes: sign * (h * 60 + mi)));
      } else {
        final off = _zones[z.toUpperCase()] ?? 0;
        dt = dt.subtract(Duration(hours: off));
      }
    }
    return dt;
  }
}
