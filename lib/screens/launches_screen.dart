import 'package:flutter/material.dart';

import '../models/launch_item.dart';
import '../services/cache_store.dart';
import '../services/launch_service.dart';
import '../widgets/launch_card.dart';
import '../widgets/section_header.dart';
import '../widgets/state_views.dart';

/// Upcoming launches from The Space Devs Launch Library 2.
///
/// The free API tier allows ~15 requests/hour, so results are cached and only
/// refetched automatically when older than [_autoRefreshAfter]. Pull-to-refresh
/// forces a fetch unless it was done in the last [_minManualInterval].
class LaunchesScreen extends StatefulWidget {
  const LaunchesScreen({super.key});

  @override
  State<LaunchesScreen> createState() => _LaunchesScreenState();
}

class _LaunchesScreenState extends State<LaunchesScreen> {
  static const _autoRefreshAfter = Duration(minutes: 30);
  static const _minManualInterval = Duration(minutes: 5);

  final _service = LaunchService();
  List<LaunchItem> _launches = const [];
  DateTime? _updatedAt;
  bool _loading = true;
  bool _fromCache = false;
  String? _error;
  String _filter = 'All';

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
    final cached = await CacheStore.loadLaunches();
    if (!mounted) return;
    if (cached != null) {
      setState(() {
        _launches = _dropPast(cached.data);
        _updatedAt = cached.fetchedAt;
        _fromCache = true;
        _loading = cached.age > _autoRefreshAfter;
      });
      if (cached.age <= _autoRefreshAfter) return;
    }
    await _fetch();
  }

  /// Hide launches whose NET is more than 6 h in the past (stale cache).
  List<LaunchItem> _dropPast(List<LaunchItem> l) {
    final cutoff = DateTime.now().toUtc().subtract(const Duration(hours: 6));
    return l.where((e) => e.net.isAfter(cutoff)).toList();
  }

  Future<void> _fetch({bool userInitiated = false}) async {
    final blocked = await CacheStore.launchBlockedUntil();
    if (!mounted) return;
    if (blocked != null && DateTime.now().isBefore(blocked)) {
      final mins = blocked.difference(DateTime.now()).inMinutes + 1;
      setState(() {
        _loading = false;
        _error = 'Launch Library rate limit — try again in ~$mins min.';
      });
      return;
    }
    if (userInitiated &&
        _updatedAt != null &&
        !_fromCache &&
        DateTime.now().difference(_updatedAt!) < _minManualInterval &&
        _launches.isNotEmpty) {
      _snack('Manifest is fresh (API limit: ~15 requests/hour)');
      return;
    }

    setState(() => _loading = true);
    try {
      final items = await _service.fetchUpcoming();
      await CacheStore.saveLaunches(items);
      if (!mounted) return;
      setState(() {
        _launches = items;
        _updatedAt = DateTime.now();
        _fromCache = false;
        _error = null;
        _loading = false;
        if (_filter != 'All' && !_providers.contains(_filter)) _filter = 'All';
      });
      if (userInitiated) _snack('Updated · ${items.length} upcoming launches');
    } on LaunchApiException catch (e) {
      if (e.retryAfter != null) {
        await CacheStore.setLaunchBlockedUntil(
            DateTime.now().add(e.retryAfter!));
      }
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Couldn\'t reach Launch Library. Check your connection.';
      });
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

  /// Provider chips built from the real data, most launches first.
  List<String> get _providers {
    final counts = <String, int>{};
    for (final l in _launches) {
      counts[l.company] = (counts[l.company] ?? 0) + 1;
    }
    final keys = counts.keys.toList()
      ..sort((a, b) {
        final c = counts[b]!.compareTo(counts[a]!);
        return c != 0 ? c : a.compareTo(b);
      });
    return keys;
  }

  List<LaunchItem> get _visible {
    if (_filter == 'All') return _launches;
    return _launches.where((l) => l.company == _filter).toList();
  }

  static String _short(String provider) {
    const map = {
      'Space Exploration Technologies Corp.': 'SpaceX',
      'SpaceX': 'SpaceX',
      'United Launch Alliance': 'ULA',
      'National Aeronautics and Space Administration': 'NASA',
      'China Aerospace Science and Technology Corporation': 'CASC',
      'Indian Space Research Organization': 'ISRO',
      'Russian Federal Space Agency (ROSCOSMOS)': 'Roscosmos',
      'Japan Aerospace Exploration Agency': 'JAXA',
      'Mitsubishi Heavy Industries': 'MHI',
      'Korea Aerospace Research Institute': 'KARI',
    };
    return map[provider] ?? provider;
  }

  @override
  Widget build(BuildContext context) {
    final items = _visible;
    final filters = ['All', ..._providers];

    Widget body;
    if (_launches.isEmpty && _loading) {
      body = const SliverFillRemaining(
        hasScrollBody: false,
        child: LoadingView(message: 'Loading launch manifest…'),
      );
    } else if (_launches.isEmpty && _error != null) {
      body = SliverFillRemaining(
        hasScrollBody: false,
        child: MessageView(
          icon: Icons.cloud_off_rounded,
          message: _error!,
          actionLabel: 'Retry',
          onAction: () => _fetch(userInitiated: true),
        ),
      );
    } else if (items.isEmpty) {
      body = SliverToBoxAdapter(
        child: MessageView(
          icon: Icons.rocket_outlined,
          message: _filter == 'All'
              ? 'No upcoming launches listed.'
              : 'No upcoming launches for ${_short(_filter)}.',
        ),
      );
    } else {
      body = SliverList.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => LaunchCard(launch: items[index]),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetch(userInitiated: true),
      color: Theme.of(context).colorScheme.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Rocket launches',
              subtitle: 'Live manifest from The Space Devs Launch Library 2',
            ),
          ),
          if (_updatedAt != null)
            SliverToBoxAdapter(
              child: UpdatedBanner(
                updatedAt: _updatedAt!,
                fromCache: _fromCache,
                refreshing: _loading,
                error: _launches.isNotEmpty ? _error : null,
              ),
            ),
          if (_launches.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final f = filters[i];
                    return FilterChip(
                      label: Text(_short(f)),
                      selected: f == _filter,
                      onSelected: (_) => setState(() => _filter = f),
                      showCheckmark: false,
                    );
                  },
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            sliver: body,
          ),
        ],
      ),
    );
  }
}
