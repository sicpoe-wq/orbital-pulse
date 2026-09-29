import 'package:flutter/material.dart';

import '../models/news_item.dart';
import '../services/cache_store.dart';
import '../services/news_service.dart';
import '../widgets/news_card.dart';
import '../widgets/section_header.dart';
import '../widgets/state_views.dart';

/// Live news list (RSS/Atom) for the Elon / Robotics / Space tabs.
class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({
    super.key,
    required this.category,
    required this.title,
    required this.subtitle,
  });

  final NewsCategory category;
  final String title;
  final String subtitle;

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  static const _staleAfter = Duration(minutes: 15);

  final _service = NewsService();
  List<NewsItem> _items = const [];
  DateTime? _updatedAt;
  bool _loading = true;
  bool _fromCache = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _service.close();
    super.dispose();
  }

  Future<void> _init() async {
    final cached = await CacheStore.loadNews(widget.category);
    if (!mounted) return;
    if (cached != null && cached.data.isNotEmpty) {
      setState(() {
        _items = cached.data;
        _updatedAt = cached.fetchedAt;
        _fromCache = true;
        _loading = cached.age > _staleAfter;
      });
      if (cached.age <= _staleAfter) return;
    }
    await _fetch();
  }

  Future<void> _fetch({bool userInitiated = false}) async {
    if (_items.isEmpty) setState(() => _loading = true);
    final result = await _service.fetchCategory(widget.category);
    if (!mounted) return;
    if (result.items.isNotEmpty) {
      await CacheStore.saveNews(widget.category, result.items);
      if (!mounted) return;
      setState(() {
        _items = result.items;
        _updatedAt = DateTime.now();
        _fromCache = false;
        _error = null;
        _loading = false;
      });
      if (userInitiated) {
        final failed = result.failedFeeds;
        _snack(failed == 0
            ? 'Updated · ${result.items.length} stories'
            : 'Updated · ${result.items.length} stories ($failed source${failed == 1 ? '' : 's'} unavailable)');
      }
    } else {
      setState(() {
        _loading = false;
        _error = 'Couldn\'t reach any news source. Check your connection and pull to retry.';
      });
      if (userInitiated && _items.isNotEmpty) {
        _snack('Offline — showing saved stories');
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

    Widget body;
    if (_items.isEmpty && _loading) {
      body = const SliverFillRemaining(
        hasScrollBody: false,
        child: LoadingView(message: 'Fetching latest stories…'),
      );
    } else if (_items.isEmpty && _error != null) {
      body = SliverFillRemaining(
        hasScrollBody: false,
        child: MessageView(
          icon: Icons.cloud_off_rounded,
          message: _error!,
          actionLabel: 'Retry',
          onAction: () => _fetch(userInitiated: true),
        ),
      );
    } else if (_items.isEmpty) {
      body = const SliverFillRemaining(
        hasScrollBody: false,
        child: MessageView(
          icon: Icons.inbox_outlined,
          message: 'No stories right now. Pull down to refresh.',
        ),
      );
    } else {
      body = SliverList.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) => NewsCard(item: _items[index]),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetch(userInitiated: true),
      color: theme.colorScheme.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SectionHeader(
              title: widget.title,
              subtitle: widget.subtitle,
            ),
          ),
          if (_updatedAt != null)
            SliverToBoxAdapter(
              child: UpdatedBanner(
                updatedAt: _updatedAt!,
                fromCache: _fromCache,
                refreshing: _loading,
                error: _items.isNotEmpty ? _error : null,
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
