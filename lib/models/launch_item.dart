/// Upcoming (or recent) rocket launch for the Launches tab.
class LaunchItem {
  const LaunchItem({
    required this.id,
    required this.missionName,
    required this.company,
    required this.vehicle,
    required this.windowStart,
    required this.pad,
    required this.payloadSummary,
    this.windowEnd,
    this.status = LaunchStatus.scheduled,
    this.streamUrl,
    this.orbit,
    this.chanceOfSuccess,
  });

  final String id;
  final String missionName;
  final String company;
  final String vehicle;
  final DateTime windowStart;
  final DateTime? windowEnd;
  final String pad;
  final String payloadSummary;
  final LaunchStatus status;
  final String? streamUrl;
  final String? orbit;
  final String? chanceOfSuccess;

  bool get hasStream => streamUrl != null && streamUrl!.isNotEmpty;
}

enum LaunchStatus {
  scheduled,
  go,
  hold,
  scrubbed,
  success,
  inFlight,
}
