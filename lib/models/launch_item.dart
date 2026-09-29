/// Upcoming rocket launch from The Space Devs Launch Library 2.
class LaunchItem {
  const LaunchItem({
    required this.id,
    required this.missionName,
    required this.company,
    required this.vehicle,
    required this.net,
    required this.pad,
    required this.payloadSummary,
    required this.statusName,
    required this.statusAbbrev,
    this.windowStart,
    this.windowEnd,
    this.streamUrl,
    this.orbit,
    this.missionType,
    this.imageUrl,
    this.infoUrl,
  });

  final String id;

  /// Full LL2 launch name, e.g. "Falcon 9 Block 5 | Starlink Group 10-12".
  final String missionName;

  /// Launch service provider name.
  final String company;
  final String vehicle;

  /// No-Earlier-Than time (UTC).
  final DateTime net;
  final DateTime? windowStart;
  final DateTime? windowEnd;
  final String pad;
  final String payloadSummary;
  final String statusName;
  final String statusAbbrev;
  final String? streamUrl;
  final String? orbit;
  final String? missionType;
  final String? imageUrl;
  final String? infoUrl;

  bool get hasStream => streamUrl != null && streamUrl!.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'missionName': missionName,
        'company': company,
        'vehicle': vehicle,
        'net': net.toUtc().toIso8601String(),
        'windowStart': windowStart?.toUtc().toIso8601String(),
        'windowEnd': windowEnd?.toUtc().toIso8601String(),
        'pad': pad,
        'payloadSummary': payloadSummary,
        'statusName': statusName,
        'statusAbbrev': statusAbbrev,
        'streamUrl': streamUrl,
        'orbit': orbit,
        'missionType': missionType,
        'imageUrl': imageUrl,
        'infoUrl': infoUrl,
      };

  static DateTime? _d(Object? v) =>
      v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;

  factory LaunchItem.fromJson(Map<String, dynamic> j) => LaunchItem(
        id: j['id'] as String,
        missionName: j['missionName'] as String,
        company: j['company'] as String,
        vehicle: j['vehicle'] as String,
        net: DateTime.parse(j['net'] as String),
        windowStart: _d(j['windowStart']),
        windowEnd: _d(j['windowEnd']),
        pad: j['pad'] as String,
        payloadSummary: j['payloadSummary'] as String,
        statusName: j['statusName'] as String,
        statusAbbrev: j['statusAbbrev'] as String,
        streamUrl: j['streamUrl'] as String?,
        orbit: j['orbit'] as String?,
        missionType: j['missionType'] as String?,
        imageUrl: j['imageUrl'] as String?,
        infoUrl: j['infoUrl'] as String?,
      );
}
