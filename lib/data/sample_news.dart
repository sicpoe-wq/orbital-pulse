import '../models/news_item.dart';

/// SAMPLE DATA — demo feed only. Replace with live API (e.g. NewsAPI / RSS) later.
class SampleNews {
  static final DateTime _now = DateTime.now();

  static List<NewsItem> all = [
    ...elon,
    ...robotics,
    ...space,
  ];

  static List<NewsItem> forCategory(NewsCategory category) {
    switch (category) {
      case NewsCategory.elon:
        return elon;
      case NewsCategory.robotics:
        return robotics;
      case NewsCategory.space:
        return space;
    }
  }

  static final List<NewsItem> elon = [
    NewsItem(
      id: 'e1',
      title: 'Starship Flight 7 clears FAA license; Pad 39A stacked for static fire',
      source: 'SpaceX Watch',
      summary:
          'Ship 33 and Booster 14 complete cryo proofing. Net-positive water deluge '
          'tests reported. Flight window opens next week pending final range clearance.',
      publishedAt: _now.subtract(const Duration(hours: 2)),
      category: NewsCategory.elon,
      tags: const ['SpaceX', 'Starship'],
      articleUrl: 'https://www.spacex.com',
    ),
    NewsItem(
      id: 'e2',
      title: 'Tesla Optimus Gen-3 hands demo: fine motor tasks in factory trial',
      source: 'Tesla AI Day Digest',
      summary:
          'Fremont pilot line shows Optimus sorting battery modules and using tools. '
          'Musk reiterates million-unit annual target by end of decade.',
      publishedAt: _now.subtract(const Duration(hours: 5)),
      category: NewsCategory.elon,
      tags: const ['Tesla', 'Optimus', 'Robotics'],
      articleUrl: 'https://www.tesla.com/AI',
    ),
    NewsItem(
      id: 'e3',
      title: 'xAI Grok multimodal update rolls out real-time vision on X',
      source: 'xAI Notes',
      summary:
          'New Grok build adds camera understanding and tool use. Memphis Colossus '
          'cluster expansion continues with next GPU tranche.',
      publishedAt: _now.subtract(const Duration(hours: 9)),
      category: NewsCategory.elon,
      tags: const ['xAI', 'Grok'],
      articleUrl: 'https://x.ai',
    ),
    NewsItem(
      id: 'e4',
      title: 'Neuralink Blindsight primate trial advances toward human IDE',
      source: 'Neuralink Blog',
      summary:
          'Visual prosthesis implant restores rudimentary light perception in study '
          'animals. Company preparing FDA interaction for first human cohort.',
      publishedAt: _now.subtract(const Duration(hours: 14)),
      category: NewsCategory.elon,
      tags: const ['Neuralink', 'BCI'],
      articleUrl: 'https://neuralink.com',
    ),
    NewsItem(
      id: 'e5',
      title: 'Boring Company Vegas Loop Phase 2 tunnels break ground',
      source: 'LV Metro Pulse',
      summary:
          'Prufrock-3 begins twin-bore corridor toward Convention Center campus. '
          'City council greenlights expanded station footprint.',
      publishedAt: _now.subtract(const Duration(days: 1, hours: 3)),
      category: NewsCategory.elon,
      tags: const ['Boring Company'],
      articleUrl: 'https://www.boringcompany.com',
    ),
    NewsItem(
      id: 'e6',
      title: 'Starlink Direct-to-Cell expands roaming deals across three continents',
      source: 'SatelliteToday',
      summary:
          'Carrier partnerships add SMS and low-rate voice over LEO. Next V2 Mini '
          'batch lifts on Falcon 9 from SLC-40 this month.',
      publishedAt: _now.subtract(const Duration(days: 1, hours: 8)),
      category: NewsCategory.elon,
      tags: const ['Starlink', 'SpaceX'],
      articleUrl: 'https://www.starlink.com',
    ),
  ];

  static final List<NewsItem> robotics = [
    NewsItem(
      id: 'r1',
      title: 'Boston Dynamics Atlas electric walks factory floor at Hyundai plant',
      source: 'IEEE Spectrum',
      summary:
          'Fully electric Atlas demonstrates bipedal logistics tasks alongside '
          'human operators. Hyundai targets limited pilot deployment in 2027.',
      publishedAt: _now.subtract(const Duration(hours: 3)),
      category: NewsCategory.robotics,
      tags: const ['Boston Dynamics', 'Atlas'],
      articleUrl: 'https://bostondynamics.com',
    ),
    NewsItem(
      id: 'r2',
      title: 'Figure 02 humanoid joins BMW Spartanburg line for sheet-metal assist',
      source: 'The Robot Report',
      summary:
          'Figure AI reports multi-hour shifts without intervention. Partnership '
          'expands from proof-of-concept to multi-station trial.',
      publishedAt: _now.subtract(const Duration(hours: 7)),
      category: NewsCategory.robotics,
      tags: const ['Figure AI', 'BMW'],
      articleUrl: 'https://www.figure.ai',
    ),
    NewsItem(
      id: 'r3',
      title: 'Unitree G1 open-source locomotion stack unlocks community mods',
      source: 'RoboHub',
      summary:
          'Chinese humanoid maker releases SDK for gait and teleop. Maker labs '
          'already shipping custom end-effectors.',
      publishedAt: _now.subtract(const Duration(hours: 12)),
      category: NewsCategory.robotics,
      tags: const ['Unitree', 'Open Source'],
      articleUrl: 'https://www.unitree.com',
    ),
    NewsItem(
      id: 'r4',
      title: 'Agility Digit warehouse robots hit 1M picks milestone at GXO',
      source: 'Warehouse Tech Weekly',
      summary:
          'Digit bipeds now handle tote moves across three US distribution sites. '
          'Uptime metrics published for first time.',
      publishedAt: _now.subtract(const Duration(days: 1)),
      category: NewsCategory.robotics,
      tags: const ['Agility', 'Digit'],
      articleUrl: 'https://www.agilityrobotics.com',
    ),
    NewsItem(
      id: 'r5',
      title: 'Apptronik Apollo partners with Mercedes for EV battery pack handling',
      source: 'Automotive News',
      summary:
          'General-purpose humanoid to assist with repetitive lift tasks. Safety '
          'cage-free collaboration under evaluation.',
      publishedAt: _now.subtract(const Duration(days: 2)),
      category: NewsCategory.robotics,
      tags: const ['Apptronik', 'Mercedes'],
      articleUrl: 'https://apptronik.com',
    ),
  ];

  static final List<NewsItem> space = [
    NewsItem(
      id: 's1',
      title: 'NASA Artemis II crew completes final integrated launch abort review',
      source: 'NASA Blog',
      summary:
          'Orion and SLS stack enter terminal countdown rehearsals at KSC. Crew '
          'quarantine timeline locked for lunar flyby mission.',
      publishedAt: _now.subtract(const Duration(hours: 4)),
      category: NewsCategory.space,
      tags: const ['NASA', 'Artemis'],
      articleUrl: 'https://www.nasa.gov/artemis',
    ),
    NewsItem(
      id: 's2',
      title: 'ESA Euclid releases first dark-matter mass map slice',
      source: 'ESA Science',
      summary:
          'Wide-field survey telescope delivers early cosmology data product. '
          'Public archive opens for community analysis.',
      publishedAt: _now.subtract(const Duration(hours: 8)),
      category: NewsCategory.space,
      tags: const ['ESA', 'Euclid'],
      articleUrl: 'https://www.esa.int',
    ),
    NewsItem(
      id: 's3',
      title: 'Blue Origin New Glenn targets second orbital flight window',
      source: 'SpaceNews',
      summary:
          'BE-4 engines cleared after post-flight inspection. Payload manifests '
          'include NASA EscaPADE-class rideshare options.',
      publishedAt: _now.subtract(const Duration(hours: 11)),
      category: NewsCategory.space,
      tags: const ['Blue Origin', 'New Glenn'],
      articleUrl: 'https://www.blueorigin.com',
    ),
    NewsItem(
      id: 's4',
      title: 'China Tianwen-2 sample-return probe en route to near-Earth asteroid',
      source: 'CNSA Watch',
      summary:
          'Probe confirmed healthy after TLI burn. Rendezvous with 2016 HO3 '
          'planned for next year before comet flyby leg.',
      publishedAt: _now.subtract(const Duration(days: 1, hours: 2)),
      category: NewsCategory.space,
      tags: const ['CNSA', 'Tianwen'],
      articleUrl: 'https://www.cnsa.gov.cn',
    ),
    NewsItem(
      id: 's5',
      title: 'Rocket Lab Electron returns to flight from Mahia after pad upgrade',
      source: 'Rocket Lab News',
      summary:
          'Pad 1A improvements cut turnaround. Next mission carries Earth-obs '
          'constellation sats for commercial customer.',
      publishedAt: _now.subtract(const Duration(days: 1, hours: 6)),
      category: NewsCategory.space,
      tags: const ['Rocket Lab', 'Electron'],
      articleUrl: 'https://www.rocketlabusa.com',
    ),
    NewsItem(
      id: 's6',
      title: 'JWST spots earliest confirmed bar in spiral galaxy at z≈3',
      source: 'Nature Astronomy',
      summary:
          'Infrared imaging revises timelines for galactic structure formation. '
          'Open data release accompanies the paper.',
      publishedAt: _now.subtract(const Duration(days: 2, hours: 4)),
      category: NewsCategory.space,
      tags: const ['JWST', 'Astronomy'],
      articleUrl: 'https://webb.nasa.gov',
    ),
  ];
}
