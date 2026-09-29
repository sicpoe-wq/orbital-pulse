import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/launch_item.dart';
import '../theme/app_theme.dart';
import 'link_opener.dart';

class LaunchCard extends StatelessWidget {
  const LaunchCard({super.key, required this.launch});

  final LaunchItem launch;

  Color get _statusColor {
    switch (launch.statusAbbrev.toLowerCase()) {
      case 'go':
        return AppTheme.accentAlt;
      case 'hold':
      case 'tbc':
        return AppTheme.warn;
      case 'in flight':
        return AppTheme.accent;
      case 'success':
        return Colors.lightGreenAccent;
      case 'failure':
      case 'partial failure':
        return Colors.redAccent;
      default:
        return Colors.white54;
    }
  }

  String get _netText {
    final local = launch.net.toLocal();
    final tz = local.timeZoneName;
    final fmt = DateFormat('EEE, MMM d, y · h:mm a');
    final ws = launch.windowStart?.toLocal();
    final we = launch.windowEnd?.toLocal();
    final base = 'NET ${fmt.format(local)} $tz';
    if (ws != null && we != null && we.isAfter(ws)) {
      final t = DateFormat('h:mm a');
      return '$base\nWindow ${t.format(ws)} – ${t.format(we)}'
          '${we.day != ws.day ? ' (+1 day)' : ''}';
    }
    return base;
  }

  String get _countdown {
    final d = launch.net.difference(DateTime.now().toUtc());
    if (d.isNegative) return 'T+ ${_fmt(-d)}';
    return 'T- ${_fmt(d)}';
  }

  static String _fmt(Duration d) {
    if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h';
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    return '${d.inMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orbitLine = [
      if (launch.missionType != null) launch.missionType!,
      if (launch.orbit != null) 'Orbit: ${launch.orbit}',
    ].join(' · ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    launch.missionName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: launch.statusName,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _statusColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      launch.statusAbbrev.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _statusColor,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${launch.company} · ${launch.vehicle}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.schedule, label: _netText, trailing: _countdown),
            _InfoRow(icon: Icons.flag_outlined, label: launch.statusName),
            _InfoRow(icon: Icons.place_outlined, label: launch.pad),
            if (orbitLine.isNotEmpty)
              _InfoRow(icon: Icons.public, label: orbitLine),
            _InfoRow(
              icon: Icons.inventory_2_outlined,
              label: launch.payloadSummary,
              maxLines: 5,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: launch.hasStream
                        ? () => openExternal(context, launch.streamUrl!)
                        : null,
                    icon: Icon(launch.hasStream
                        ? Icons.play_circle_outline
                        : Icons.videocam_off_outlined),
                    label: Text(
                        launch.hasStream ? 'Watch stream' : 'No webcast yet'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (launch.infoUrl != null) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => openExternal(context, launch.infoUrl!),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Details'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    this.trailing,
    this.maxLines,
  });

  final IconData icon;
  final String label;
  final String? trailing;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white70,
          height: 1.35,
        );
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.white38),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: maxLines,
              overflow: maxLines != null ? TextOverflow.ellipsis : null,
              style: style,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Text(
              trailing!,
              style: style?.copyWith(
                color: AppTheme.accentAlt,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
