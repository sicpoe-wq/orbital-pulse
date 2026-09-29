import 'package:flutter/material.dart';

import '../models/news_item.dart';
import '../models/video_item.dart';
import '../services/cache_store.dart';
import '../services/video_service.dart';
import '../widgets/section_header.dart';
import '../widgets/state_views.dart';
import '../widgets/video_card.dart';

class _CatState {
  List<VideoItem> items = const [];
  DateTime? updatedAt;
  bool loading = true;
  bool fromCache = false;
  bool started = false;
  String? error;
}

/// Newest real YouTube videos from verified channel RSS feeds, per category.
class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  static const _staleAfter = Duration(minutes: 15);

  static const _labels = {
    NewsCategory.elon: 'Elon',
    NewsCategory.robotics: 'Robotics',
    NewsCategory.space: 'Space',
  };
  static const _subtitles = {
    NewsCategory.elon: 'SpaceX · Tesla · xAI · Neuralink · Starlink',
    NewsCategory.robotics: 'Humanoids and robot makers',
    NewsCategory.space: 'Agencies, launches, and space news channels',
  };

  final _service = VideoService();
  final _states = {for (final c in NewsCategory.values) c: _CatState()};
  NewsCategory _cat = NewsCategory.elon;

  _CatState get _s => _states[_cat]!;

  @override
  void initState() {
    super.initState();
    _ensureLoaded(_cat);
  }

  @override
  void dispose() {
    _service.close();
    super.dispose();
  }

  void _select(NewsCategory c) {
    setState(() => _cat = c);
    _ensureLoaded(c);
  }

  Future<void> _ensureLoaded(NewsCategory c) async {
    final s = _states[c]!;
    if (s.started) return;
    s.started = true;
    final cached = await CacheStore.loadVideos(c);
    if (!mounted) return;
    if (cached != null && cached.data.isNotEmpty) {
      setState(() {
        s.items = cached.data;
        s.updatedAt = cached.fetchedAt;
        s.fromCache = true;
        s.loading = cached.age > _staleAfter;
      });
      if (cached.age <= _staleAfter) return;
    }
    await _fetch(c);
  }

  Future<void> _fetch(NewsCategory c, {bool userInitiated = false}) async {
    final s = _states[c]!;
    setState(() => s.loading = true);
    final result = await _service.fetchCategory(c);
    if (!mounted) return;
    if (result.items.isNotEmpty) {
      await CacheStore.saveVideos(c, result.items);
      if (!mounted) return;
      setState(() {
        s.items = result.items;
        s.updatedAt = DateTime.now();
        s.fromCache = false;
        s.error = null;
        s.loading = false;
      });
      if (userInitiated) {
        final failed = result.failedChannels;
        _snack(failed == 0
            ? 'Updated · ${result.items.length} videos'
            : 'Updated · ${result.items.length} videos ($failed channel${failed == 1 ? '' : 's'} unavailable)');
      }
    } else {
      setState(() {
        s.loading = false;
        s.error =
            'Couldn\'t reach YouTube. Check your connection and pull to retry.';
      });
      if (userInitiated && s.items.isNotEmpty) {
        _snack('Offline — showing saved videos');
      }
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = _s;
    final cat = _cat;

    Widget body;
    if (s.items.isEmpty && s.loading) {
      body = const SliverFillRemaining(
        hasScrollBody: false,
        child: LoadingView(message: 'Fetching latest videos…'),
      );
    } else if (s.items.isEmpty && s.error != null) {
      body = SliverFillRemaining(
        hasScrollBody: false,
        child: MessageView(
          icon: Icons.cloud_off_rounded,
          message: s.error!,
          actionLabel: 'Retry',
          onAction: () => _fetch(cat, userInitiated: true),
        ),
      );
    } else if (s.items.isEmpty) {
      body = const SliverFillRemaining(
        hasScrollBody: false,
        child: MessageView(
          icon: Icons.video_library_outlined,
          message: 'No videos right now. Pull down to refresh.',
        ),
      );
    } else {
      body = SliverList.builder(
        itemCount: s.items.length,
        itemBuilder: (context, i) => VideoCard(item: s.items[i]),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetch(cat, userInitiated: true),
      color: theme.colorScheme.primary,
      child: CustomScrollView(
        key: PageStorageKey('videos_${cat.name}'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Latest videos',
              subtitle: _subtitles[cat],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Wrap(
                spacing: 8,
                children: [
                  for (final c in NewsCategory.values)
                    ChoiceChip(
                      label: Text(_labels[c]!),
                      selected: c == cat,
                      onSelected: (_) => _select(c),
                    ),
                ],
              ),
            ),
          ),
          if (s.updatedAt != null)
            SliverToBoxAdapter(
              child: UpdatedBanner(
                updatedAt: s.updatedAt!,
                fromCache: s.fromCache,
                refreshing: s.loading,
                error: s.items.isNotEmpty ? s.error : null,
                note: 'YouTube',
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 4, bottom: 24),
            sliver: body,
          ),
        ],
      ),
    );
  }
}
