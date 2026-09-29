import 'package:flutter/material.dart';

import '../data/sample_launches.dart';
import '../models/launch_item.dart';
import '../widgets/launch_card.dart';
import '../widgets/section_header.dart';

class LaunchesScreen extends StatefulWidget {
  const LaunchesScreen({super.key});

  @override
  State<LaunchesScreen> createState() => _LaunchesScreenState();
}

class _LaunchesScreenState extends State<LaunchesScreen> {
  late List<LaunchItem> _launches;
  String _filter = 'All';

  static const _filters = [
    'All',
    'SpaceX',
    'ULA',
    'Blue Origin',
    'Rocket Lab',
    'Arianespace',
  ];

  @override
  void initState() {
    super.initState();
    _launches = List.of(SampleLaunches.upcoming)
      ..sort((a, b) => a.windowStart.compareTo(b.windowStart));
  }

  List<LaunchItem> get _visible {
    if (_filter == 'All') return _launches;
    return _launches.where((l) => l.company == _filter).toList();
  }

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _launches = List.of(SampleLaunches.upcoming)
        ..sort((a, b) => a.windowStart.compareTo(b.windowStart));
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Launch manifest refreshed (sample data)'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _visible;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: Theme.of(context).colorScheme.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Rocket launches',
              subtitle: 'Upcoming windows · tap Watch stream for live coverage',
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final f = _filters[i];
                  final selected = f == _filter;
                  return FilterChip(
                    label: Text(f),
                    selected: selected,
                    onSelected: (_) => setState(() => _filter = f),
                    showCheckmark: false,
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            sliver: items.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No launches for $_filter in the sample set.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white54),
                      ),
                    ),
                  )
                : SliverList.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) =>
                        LaunchCard(launch: items[index]),
                  ),
          ),
        ],
      ),
    );
  }
}
