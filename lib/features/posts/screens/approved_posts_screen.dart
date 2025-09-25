import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../posts/models/post.dart';
import '../notifiers/approved_post_notifier.dart';

class ApprovedPostsScreen extends ConsumerWidget {
  const ApprovedPostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approvedPosts = ref.watch(approvedPostsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Approved Posts'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: approvedPosts.isEmpty
              ? const Center(child: Text('No approved posts'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: approvedPosts
                        .map(
                          (post) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ApprovedPostRow(post: post),
                          ),
                        )
                        .toList(),
                  ),
                ),
        ),
      ),
    );
  }
}

class ApprovedPostRow extends ConsumerWidget {
  final Post post;
  const ApprovedPostRow({required this.post, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Name and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  post.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Approved',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Address and description
          Text(
            post.address,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            post.description,
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Prices
          Row(
            children: [
              Text('Daily: \$${post.dailyPrice.toStringAsFixed(2)}'),
              const SizedBox(width: 16),
              Text('Weekly: \$${post.weeklyPrice.toStringAsFixed(2)}'),
              const SizedBox(width: 16),
              Text('Monthly: \$${post.monthlyPrice.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 8),

          // Images
          if (post.imageUrls.isNotEmpty)
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: post.imageUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    post.imageUrls[i],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),

          // Delete button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: () async {
                final confirm = await _showConfirmDialog(
                  context,
                  'Delete post "${post.name}"?',
                );
                if (confirm) {
                  await ref
                      .read(approvedPostsProvider.notifier)
                      .deletePost(post.id);
                }
              },
              icon: const Icon(Icons.delete, color: Colors.white, size: 18),
              label: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Confirmation dialog with rounded corners
  static Future<bool> _showConfirmDialog(
    BuildContext context,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
