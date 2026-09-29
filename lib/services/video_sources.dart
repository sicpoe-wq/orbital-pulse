import '../models/news_item.dart';

/// A YouTube channel whose public RSS feed populates the Videos tab.
class VideoChannel {
  const VideoChannel({
    required this.name,
    required this.channelId,
    this.tag,
    this.keywords,
    this.maxItems = 15,
  });

  final String name;

  /// Real YouTube channel id (UC…), verified with curl.
  final String channelId;

  /// Tag applied to every video from this channel (e.g. "SpaceX").
  final String? tag;

  /// When set, only videos whose title matches are kept (for channels that
  /// also cover unrelated topics).
  final RegExp? keywords;
  final int maxItems;

  String get feedUrl =>
      'https://www.youtube.com/feeds/videos.xml?channel_id=$channelId';
}

final _elonKw = RegExp(
    r'spacex|starship|starlink|starbase|falcon|dragon|tesla|optimus|cybertruck|'
    r'cybercab|robotaxi|\bfsd\b|model [3sxy]\b|megapack|roadster|semi\b|elon|musk|'
    r'\bxai\b|grok|colossus|neuralink|boring company|hyperloop',
    caseSensitive: false);

final _spacexKw = RegExp(r'spacex|starship|starlink|starbase|falcon|dragon|elon|musk',
    caseSensitive: false);

final _roboticsKw = RegExp(
    r'robot|humanoid|drone|autonom|android|exoskeleton|bionic|optimus',
    caseSensitive: false);

/// Keyword → tag rules for the Elon category chips on each card.
final Map<String, RegExp> elonTagRules = {
  'SpaceX': RegExp(r'spacex|starship|starbase|falcon|dragon|raptor', caseSensitive: false),
  'Starlink': RegExp(r'starlink', caseSensitive: false),
  'Tesla': RegExp(
      r'tesla|optimus|cybertruck|cybercab|robotaxi|\bfsd\b|model [3sxy]\b|megapack|roadster',
      caseSensitive: false),
  'xAI': RegExp(r'\bxai\b|grok|colossus|spacexai', caseSensitive: false),
  'Neuralink': RegExp(r'neuralink', caseSensitive: false),
  'Boring Co': RegExp(r'boring company|hyperloop', caseSensitive: false),
};

/// All channel ids were resolved from their @handles and verified with curl to
/// return entries from youtube.com/feeds/videos.xml (Sep 2026).
class VideoSources {
  static final Map<NewsCategory, List<VideoChannel>> byCategory = {
    NewsCategory.elon: [
      const VideoChannel(name: 'SpaceX', channelId: 'UCtI0Hodo5o5dUb67FeUjDeA', tag: 'SpaceX'),
      const VideoChannel(name: 'Tesla', channelId: 'UC5WjFrtBdufl6CZojX3D8dQ', tag: 'Tesla'),
      const VideoChannel(name: 'Grok (xAI)', channelId: 'UCxgo0OMZU9SiaYpJsuZKWkQ', tag: 'xAI'),
      const VideoChannel(name: 'Neuralink', channelId: 'UCLt4d8cACHzrVvAz9gtaARA', tag: 'Neuralink'),
      VideoChannel(name: 'Solving The Money Problem', channelId: 'UCagiBBx1prefrlsDzDxuA9A', keywords: _elonKw, maxItems: 10),
      VideoChannel(name: 'Dr. Know-it-all', channelId: 'UCyqpZ8HY9FY5jH-RoVcwlnw', keywords: _elonKw, maxItems: 10),
      VideoChannel(name: 'The Tesla Space', channelId: 'UCJjAIBWeY022ZNj_Cp_6wAw', keywords: _elonKw, maxItems: 8),
      // Space channels: only their SpaceX / Starship / Starlink coverage.
      VideoChannel(name: 'NASASpaceflight', channelId: 'UCSUu1lih2RifWkKtDOJdsBA', keywords: _spacexKw, maxItems: 8),
      VideoChannel(name: 'Scott Manley', channelId: 'UCxzC4EngIsMrPmbm6Nxvb-A', keywords: _spacexKw, maxItems: 5),
      VideoChannel(name: 'What about it!?', channelId: 'UC1XvxnHFtWruS9egyFasP1Q', keywords: _spacexKw, maxItems: 6),
    ],
    NewsCategory.robotics: [
      const VideoChannel(name: 'Boston Dynamics', channelId: 'UC7vVhkEfw4nOGp8TyDk7RcQ'),
      const VideoChannel(name: 'Figure', channelId: 'UCYlq-KmwPjc1DtsGmthFqSQ'),
      const VideoChannel(name: 'Unitree Robotics', channelId: 'UCsMbp4V8oxzHCMdOUP-3oWw'),
      const VideoChannel(name: 'Agility Robotics', channelId: 'UCN-StetwWuVYf-MU2_NVj4A'),
      const VideoChannel(name: 'Sanctuary AI', channelId: 'UC_d_dGoi2ztmAgiDwRh3uJw'),
      VideoChannel(name: 'IEEE Spectrum', channelId: 'UCFQDtftsHGzSh1-TReNT4lA', keywords: _roboticsKw),
      VideoChannel(name: 'Tesla', channelId: 'UC5WjFrtBdufl6CZojX3D8dQ', tag: 'Optimus', keywords: RegExp('optimus', caseSensitive: false)),
    ],
    NewsCategory.space: [
      const VideoChannel(name: 'NASA', channelId: 'UCLA_DiR1FfKNvjuUpBHmylQ'),
      const VideoChannel(name: 'NASASpaceflight', channelId: 'UCSUu1lih2RifWkKtDOJdsBA'),
      const VideoChannel(name: 'Everyday Astronaut', channelId: 'UC6uKrU_WqJ1R2HMTY3LIx5Q'),
      const VideoChannel(name: 'Scott Manley', channelId: 'UCxzC4EngIsMrPmbm6Nxvb-A'),
      const VideoChannel(name: 'Marcus House', channelId: 'UCBNHHEoiSF8pcLgqLKVugOw'),
      const VideoChannel(name: 'European Space Agency', channelId: 'UCIBaDdAbGlFDeS33shmlD0A', maxItems: 10),
      const VideoChannel(name: 'SpaceX', channelId: 'UCtI0Hodo5o5dUb67FeUjDeA', maxItems: 8),
      const VideoChannel(name: 'Blue Origin', channelId: 'UCVxTHEKKLxNjGcvVaZindlg', maxItems: 6),
    ],
  };
}
