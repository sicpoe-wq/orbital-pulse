import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/news_item.dart';
import '../theme/app_theme.dart';
import 'link_opener.dart';

class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.item});

  final NewsItem item;

  String get _relativeTime {
    final local = item.publishedAt.toLocal();
    final diff = DateTime.now().difference(local);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat.MMMd().format(local);
  }

  String get _host {
    final h = Uri.tryParse(item.articleUrl)?.host ?? '';
    return h.startsWith('www.') ? h.substring(4) : h;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exactTime =
        DateFormat('MMM d, y · h:mm a').format(item.publishedAt.toLocal());

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openExternal(context, item.articleUrl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (item.imageUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: Colors.white.withValues(alpha: 0.04)),
                  errorWidget: (_, __, ___) =>
                      Container(color: Colors.white.withValues(alpha: 0.04)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.source,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppTheme.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: exactTime,
                        child: Text(
                          _relativeTime,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  if (item.summary.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.summary,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.open_in_new,
                          size: 14, color: Colors.white38),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '$exactTime · $_host',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: Colors.white38),
                        ),
                      ),
                    ],
                  ),
                  if (item.tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: item.tags
                          .map(
                            (t) => Chip(
                              label: Text(t),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
