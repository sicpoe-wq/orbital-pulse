import 'package:flutter/material.dart';

import '../models/news_item.dart';
import 'launches_screen.dart';
import 'news_feed_screen.dart';
import 'videos_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _titles = [
    'Elon Pulse',
    'Robotics',
    'Space Tech',
    'Launches',
    'Videos',
  ];

  late final List<Widget> _pages = [
    const NewsFeedScreen(
      category: NewsCategory.elon,
      title: 'Elon projects',
      subtitle: 'SpaceX · Tesla · xAI · Neuralink · Boring Company',
    ),
    const NewsFeedScreen(
      category: NewsCategory.robotics,
      title: 'Robotics worldwide',
      subtitle: 'Humanoids, warehouse bots, and autonomy advances',
    ),
    const NewsFeedScreen(
      category: NewsCategory.space,
      title: 'Space technology',
      subtitle: 'Agencies, observatories, and orbital industry',
    ),
    const LaunchesScreen(),
    const VideosScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.rocket_launch_rounded,
              color: Theme.of(context).colorScheme.secondary,
              size: 22,
            ),
            const SizedBox(width: 10),
            const Text('OrbitalPulse'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                _titles[_index],
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white54,
                    ),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.bolt_outlined),
            selectedIcon: Icon(Icons.bolt),
            label: 'Elon',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy),
            label: 'Robotics',
          ),
          NavigationDestination(
            icon: Icon(Icons.public_outlined),
            selectedIcon: Icon(Icons.public),
            label: 'Space',
          ),
          NavigationDestination(
            icon: Icon(Icons.rocket_outlined),
            selectedIcon: Icon(Icons.rocket),
            label: 'Launches',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_display_outlined),
            selectedIcon: Icon(Icons.smart_display),
            label: 'Videos',
          ),
        ],
      ),
    );
  }
}
