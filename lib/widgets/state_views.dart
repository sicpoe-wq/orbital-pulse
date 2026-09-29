import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}

class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.white38),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white70),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Updated 5 min ago" line, with offline / error hints.
class UpdatedBanner extends StatelessWidget {
  const UpdatedBanner({
    super.key,
    required this.updatedAt,
    required this.fromCache,
    required this.refreshing,
    this.error,
    this.note,
  });

  final DateTime updatedAt;
  final bool fromCache;
  final bool refreshing;
  final String? error;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final diff = DateTime.now().difference(updatedAt);
    final when = diff.inMinutes < 1
        ? 'just now'
        : diff.inMinutes < 60
            ? '${diff.inMinutes} min ago'
            : DateFormat('MMM d, h:mm a').format(updatedAt);
    final parts = <String>[
      'Updated $when',
      if (fromCache) 'saved copy',
      if (refreshing) 'refreshing…',
      if (note != null) note!,
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(34, 2, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            parts.join(' · '),
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: Colors.white38),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                error!,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: Colors.orangeAccent),
              ),
            ),
        ],
      ),
    );
  }
}
