import 'package:flutter_test/flutter_test.dart';
import 'package:orbital_pulse/models/news_item.dart';
import 'package:orbital_pulse/services/feed_parser.dart';
import 'package:orbital_pulse/services/feed_sources.dart';
import 'package:orbital_pulse/services/launch_service.dart';

void main() {
  test('parses RFC 822 dates with offsets', () {
    expect(FeedParser.parseDate('Mon, 28 Sep 2026 21:48:56 +0000'),
        DateTime.utc(2026, 9, 28, 21, 48, 56));
    expect(FeedParser.parseDate('Mon, 28 Sep 2026 17:48:56 -0400'),
        DateTime.utc(2026, 9, 28, 21, 48, 56));
    expect(FeedParser.parseDate('Mon, 28 Sep 2026 22:09:55 GMT'),
        DateTime.utc(2026, 9, 28, 22, 9, 55));
    expect(FeedParser.parseDate('2026-09-28T21:48:56Z'),
        DateTime.utc(2026, 9, 28, 21, 48, 56));
  });

  test('Google News item: real publisher, stripped title, article link', () {
    const xml = '''<?xml version="1.0"?><rss version="2.0"><channel>
<item><title>Boring Co raises money - Reuters</title>
<link>https://news.google.com/rss/articles/ABC?oc=5</link>
<pubDate>Mon, 28 Sep 2026 22:09:55 GMT</pubDate>
<description>&lt;a href="x"&gt;Boring Co raises money&lt;/a&gt;</description>
<source url="https://www.reuters.com">Reuters</source></item>
</channel></rss>''';
    const src = FeedSource(name: 'Google News', url: 'x', isGoogleNews: true);
    final items = FeedParser.parse(xml, src, NewsCategory.elon);
    expect(items, hasLength(1));
    expect(items.first.title, 'Boring Co raises money');
    expect(items.first.source, 'Reuters');
    expect(items.first.articleUrl, 'https://news.google.com/rss/articles/ABC?oc=5');
    expect(items.first.summary, isEmpty);
  });

  test('RSS item with media thumbnail', () {
    const xml = '''<?xml version="1.0"?><rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/"><channel>
<item><title>Robot &amp; arm</title><link>https://example.org/2026/robot-arm/</link>
<pubDate>Mon, 28 Sep 2026 21:48:56 +0000</pubDate>
<description><![CDATA[<p>Hello <b>world</b></p>]]></description>
<media:content url="https://example.org/a.jpg" medium="image"/></item>
</channel></rss>''';
    const src = FeedSource(name: 'Example', url: 'x');
    final it = FeedParser.parse(xml, src, NewsCategory.robotics).single;
    expect(it.title, 'Robot & arm');
    expect(it.summary, 'Hello world');
    expect(it.imageUrl, 'https://example.org/a.jpg');
    expect(it.source, 'Example');
  });

  test('parses LL2 2.3.0 launch JSON', () {
    final l = LaunchService.parseLaunch({
      'id': 'abc',
      'name': 'Falcon 9 Block 5 | Starlink Group 10-1',
      'net': '2026-10-01T12:00:00Z',
      'window_start': '2026-10-01T12:00:00Z',
      'window_end': '2026-10-01T16:00:00Z',
      'status': {'name': 'Go for Launch', 'abbrev': 'Go'},
      'launch_service_provider': {'name': 'SpaceX'},
      'rocket': {
        'configuration': {'full_name': 'Falcon 9 Block 5'}
      },
      'mission': {
        'name': 'Starlink Group 10-1',
        'description': 'Batch of Starlink satellites.',
        'type': 'Communications',
        'orbit': {'name': 'Low Earth Orbit'}
      },
      'pad': {
        'name': 'SLC-40',
        'location': {'name': 'Cape Canaveral SFS, FL, USA'}
      },
      'vid_urls': [
        {'url': 'https://x.com/SpaceX/status/1', 'priority': 10},
        {'url': 'https://www.youtube.com/watch?v=abc', 'priority': 1},
      ],
    })!;
    expect(l.company, 'SpaceX');
    expect(l.vehicle, 'Falcon 9 Block 5');
    expect(l.orbit, 'Low Earth Orbit');
    expect(l.streamUrl, 'https://www.youtube.com/watch?v=abc');
    expect(l.pad, 'SLC-40, Cape Canaveral SFS, FL, USA');
  });
}
