import 'package:flutter/material.dart';

import '../data/sample_news.dart';
import '../models/news_item.dart';
import '../widgets/news_card.dart';
import '../widgets/section_header.dart';

/// Shared news list with pull-to-refresh stub for Elon / Robotics / Space tabs.
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
  late List<NewsItem> _items;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _items = List.of(SampleNews.forCategory(widget.category));
  }

  Future<void> _onRefresh() async {
    setState(() => _refreshing = true);
    // Stub: simulate network fetch; keep sample data for demo.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _items = List.of(SampleNews.forCategory(widget.category));
      _refreshing = false;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feed refreshed (sample data)'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: Theme.of(context).colorScheme.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SectionHeader(
              title: widget.title,
              subtitle: widget.subtitle,
            ),
          ),
          if (_refreshing)
            const SliverToBoxAdapter(
              child: LinearProgressIndicator(minHeight: 2),
            ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            sliver: SliverList.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) => NewsCard(item: _items[index]),
            ),
          ),
        ],
      ),
    );
  }
}
