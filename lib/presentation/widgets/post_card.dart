import 'package:flutter/material.dart';

import '../../domain/entities/post.dart';

// One card in the home feed: author, content, and a relative timestamp.
// Kept as its own widget so HomeScreen's ListView.builder doesn't build
// this layout inline for every post.
class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post});

  final Post post;

  String _formatTimestamp(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(post.authorName.isNotEmpty ? post.authorName[0] : '?')),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                Text(
                  _formatTimestamp(post.timestamp),
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(post.content),
          ],
        ),
      ),
    );
  }
}
