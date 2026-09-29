import 'package:flutter_test/flutter_test.dart';
import 'package:orbital_pulse/models/news_item.dart';
import 'package:orbital_pulse/models/video_item.dart';
import 'package:orbital_pulse/services/video_parser.dart';
import 'package:orbital_pulse/services/video_service.dart';
import 'package:orbital_pulse/services/video_sources.dart';
import 'package:orbital_pulse/widgets/video_card.dart';

String _entry(String id, String title, String published,
        {String? link, int views = 1234}) =>
    '''<entry>
  <id>yt:video:$id</id><yt:videoId>$id</yt:videoId>
  <yt:channelId>UCxzC4EngIsMrPmbm6Nxvb-A</yt:channelId>
  <title>$title</title>
  <link rel="alternate" href="${link ?? 'https://www.youtube.com/watch?v=$id'}"/>
  <author><name>Scott Manley</name></author>
  <published>$published</published>
  <media:group>
   <media:title>$title</media:title>
   <media:thumbnail url="https://i3.ytimg.com/vi/$id/hqdefault.jpg" width="480" height="360"/>
   <media:community><media:statistics views="$views"/></media:community>
  </media:group>
</entry>''';

String _feed(List<String> entries) =>
    '''<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns:yt="http://www.youtube.com/xml/schemas/2015" xmlns:media="http://search.yahoo.com/mrss/" xmlns="http://www.w3.org/2005/Atom">
 <title>Scott Manley</title>
 <published>2006-07-08T19:35:43+00:00</published>
 ${entries.join('\n')}
</feed>''';

void main() {
  const ch = VideoChannel(name: 'Scott Manley', channelId: 'UCxzC4EngIsMrPmbm6Nxvb-A');

  test('parses YouTube channel Atom entry', () {
    final xml = _feed([
      _entry('BznLzTXhNaI', 'Orbit Day - Starship Finally Takes A Big Leap',
          '2026-09-29T01:45:52+00:00', views: 141583),
    ]);
    final v = VideoParser.parse(xml, ch, NewsCategory.elon).single;
    expect(v.videoId, 'BznLzTXhNaI');
    expect(v.title, 'Orbit Day - Starship Finally Takes A Big Leap');
    expect(v.channel, 'Scott Manley');
    expect(v.url, 'https://www.youtube.com/watch?v=BznLzTXhNaI');
    expect(v.thumbnailUrl, 'https://i3.ytimg.com/vi/BznLzTXhNaI/hqdefault.jpg');
    expect(v.views, 141583);
    expect(v.publishedAt, DateTime.utc(2026, 9, 29, 1, 45, 52));
    expect(v.isShort, isFalse);
    expect(v.tags, contains('SpaceX'));
  });

  test('detects shorts, applies keyword filter and maxItems', () {
    final xml = _feed([
      _entry('AAAAAAAAAAA', 'Starlink V3 deploy #shorts', '2026-09-28T00:00:00+00:00',
          link: 'https://www.youtube.com/shorts/AAAAAAAAAAA'),
      _entry('BBBBBBBBBBB', 'Claude found something in DNA', '2026-09-27T00:00:00+00:00'),
      _entry('CCCCCCCCCCC', 'Tesla Optimus update', '2026-09-26T00:00:00+00:00'),
      _entry('DDDDDDDDDDD', 'SpaceX Falcon 9 landing', '2026-09-25T00:00:00+00:00'),
    ]);
    final filtered = VideoChannel(
        name: 'X', channelId: 'UC1', maxItems: 2,
        keywords: RegExp('tesla|starlink|spacex', caseSensitive: false));
    final items = VideoParser.parse(xml, filtered, NewsCategory.elon);
    expect(items.map((v) => v.videoId), ['AAAAAAAAAAA', 'CCCCCCCCCCC']);
    expect(items.first.isShort, isTrue);
    expect(items.first.tags, contains('Starlink'));
    expect(items[1].tags, contains('Tesla'));
  });

  test('skips entries without a valid video id', () {
    final xml = _feed([_entry('bad', 'x', '2026-09-28T00:00:00+00:00')]);
    expect(VideoParser.parse(xml, ch, NewsCategory.space), isEmpty);
  });

  test('merge dedupes by id, unions tags, sorts newest first', () {
    VideoItem v(String id, String t, List<String> tags) => VideoItem(
          videoId: id, title: id, channel: 'c', channelId: 'UC',
          publishedAt: DateTime.parse(t), category: NewsCategory.elon,
          url: 'https://www.youtube.com/watch?v=$id',
          thumbnailUrl: 'https://i.ytimg.com/vi/$id/hqdefault.jpg', tags: tags);
    final out = VideoService.mergeAndDedupe([
      v('old', '2026-09-01T00:00:00Z', const ['Tesla']),
      v('new', '2026-09-28T00:00:00Z', const ['SpaceX']),
      v('new', '2026-09-28T00:00:00Z', const ['Starlink']),
    ]);
    expect(out.map((e) => e.videoId), ['new', 'old']);
    expect(out.first.tags, containsAll(['SpaceX', 'Starlink']));
  });

  test('VideoItem JSON round-trip', () {
    final v = VideoItem(
        videoId: 'BznLzTXhNaI', title: 't', channel: 'c', channelId: 'UC',
        publishedAt: DateTime.utc(2026, 9, 29), category: NewsCategory.space,
        url: 'https://www.youtube.com/watch?v=BznLzTXhNaI',
        thumbnailUrl: 'https://i.ytimg.com/vi/BznLzTXhNaI/hqdefault.jpg',
        views: 5, isShort: true, tags: const ['NASA']);
    final r = VideoItem.fromJson(v.toJson());
    expect(r.videoId, v.videoId);
    expect(r.publishedAt, v.publishedAt);
    expect(r.views, 5);
    expect(r.isShort, isTrue);
    expect(r.tags, ['NASA']);
  });

  test('all configured channel ids look like real UC ids', () {
    for (final list in VideoSources.byCategory.values) {
      for (final c in list) {
        expect(c.channelId, matches(RegExp(r'^UC[A-Za-z0-9_-]{22}$')), reason: c.name);
      }
    }
  });

  test('formats view counts', () {
    expect(formatViews(1), '1 view');
    expect(formatViews(950), '950 views');
    expect(formatViews(141583), '142K views');
    expect(formatViews(2500000), '2.5M views');
  });
}
