import 'package:xml/xml.dart';

import '../models/news_item.dart';
import '../models/video_item.dart';
import 'video_sources.dart';

/// Parses a YouTube channel Atom feed into [VideoItem]s. Pure Dart.
class VideoParser {
  static List<VideoItem> parse(
    String body,
    VideoChannel channel,
    NewsCategory category,
  ) {
    final root = XmlDocument.parse(body).rootElement;
    final out = <VideoItem>[];
    for (final e in root.findElements('entry', namespace: '*')) {
      final v = _entry(e, channel, category);
      if (v == null) continue;
      if (channel.keywords != null && !channel.keywords!.hasMatch(v.title)) {
        continue;
      }
      out.add(v);
      if (out.length >= channel.maxItems) break;
    }
    return out;
  }

  static XmlElement? _child(XmlElement e, String local) =>
      e.childElements.where((c) => c.name.local == local).firstOrNull;

  static String? _text(XmlElement e, String local) {
    final t = _child(e, local)?.innerText.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  static final _idRe = RegExp(r'^[A-Za-z0-9_-]{11}$');

  static VideoItem? _entry(XmlElement e, VideoChannel ch, NewsCategory cat) {
    final id = _text(e, 'videoId');
    final title = _text(e, 'title');
    final published = DateTime.tryParse(_text(e, 'published') ?? '');
    if (id == null || !_idRe.hasMatch(id) || title == null || published == null) {
      return null;
    }
    var url = 'https://www.youtube.com/watch?v=$id';
    for (final l in e.childElements.where((c) => c.name.local == 'link')) {
      final href = l.getAttribute('href');
      if (href != null &&
          href.startsWith('https://www.youtube.com/') &&
          href.contains(id)) {
        url = href;
        break;
      }
    }
    final group = _child(e, 'group');
    var thumb = 'https://i.ytimg.com/vi/$id/hqdefault.jpg';
    int? views;
    if (group != null) {
      final t = _child(group, 'thumbnail')?.getAttribute('url');
      if (t != null && t.startsWith('https://')) thumb = t;
      final community = _child(group, 'community');
      final stats = community == null ? null : _child(community, 'statistics');
      views = int.tryParse(stats?.getAttribute('views') ?? '');
    }
    final author = _child(e, 'author');
    final channelName =
        ch.name.isNotEmpty ? ch.name : (author == null ? '' : _text(author, 'name') ?? '');

    final tags = <String>{if (ch.tag != null) ch.tag!};
    if (cat == NewsCategory.elon) {
      elonTagRules.forEach((tag, re) {
        if (re.hasMatch(title)) tags.add(tag);
      });
    }

    return VideoItem(
      videoId: id,
      title: title,
      channel: channelName,
      channelId: ch.channelId,
      publishedAt: published.toUtc(),
      category: cat,
      url: url,
      thumbnailUrl: thumb,
      views: views,
      isShort: url.contains('/shorts/'),
      tags: tags.toList(),
    );
  }
}
