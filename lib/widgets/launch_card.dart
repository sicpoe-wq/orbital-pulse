import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/launch_item.dart';
import '../theme/app_theme.dart';

class LaunchCard extends StatelessWidget {
  const LaunchCard({super.key, required this.launch});

  final LaunchItem launch;

  Color get _statusColor {
    switch (launch.status) {
      case LaunchStatus.go:
        return AppTheme.accentAlt;
      case LaunchStatus.hold:
      case LaunchStatus.scrubbed:
        return AppTheme.warn;
      case LaunchStatus.inFlight:
        return AppTheme.accent;
      case LaunchStatus.success:
        return Colors.lightGreenAccent;
      case LaunchStatus.scheduled:
        return Colors.white54;
    }
  }

  String get _statusLabel {
    switch (launch.status) {
      case LaunchStatus.go:
        return 'GO';
      case LaunchStatus.hold:
        return 'HOLD';
      case LaunchStatus.scrubbed:
        return 'SCRUB';
      case LaunchStatus.inFlight:
        return 'LIVE';
      case LaunchStatus.success:
        return 'SUCCESS';
      case LaunchStatus.scheduled:
        return 'TBD';
    }
  }

  String get _windowText {
    final fmt = DateFormat('EEE, MMM d · HH:mm');
    final start = fmt.format(launch.windowStart.toLocal());
    if (launch.windowEnd == null) return '$start local';
    final end = DateFormat('HH:mm').format(launch.windowEnd!.toLocal());
    return '$start – $end local';
  }

  Future<void> _openStream() async {
    final url = launch.streamUrl;
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    launch.missionName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
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
                    _statusLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _statusColor,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
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
            _InfoRow(icon: Icons.schedule, label: _windowText),
            _InfoRow(icon: Icons.place_outlined, label: launch.pad),
            _InfoRow(
              icon: Icons.inventory_2_outlined,
              label: launch.payloadSummary,
            ),
            if (launch.orbit != null)
              _InfoRow(icon: Icons.public, label: 'Orbit: ${launch.orbit}'),
            if (launch.chanceOfSuccess != null)
              _InfoRow(
                icon: Icons.verified_outlined,
                label: 'Est. success: ${launch.chanceOfSuccess}',
              ),
            if (launch.hasStream) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _openStream,
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text('Watch stream'),
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
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    height: 1.35,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
