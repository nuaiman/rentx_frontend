import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../posts/models/post.dart';
import '../notifiers/pending_post_notifier.dart';

class PendingPostsScreen extends ConsumerWidget {
  const PendingPostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingPosts = ref.watch(pendingPostsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Posts'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: pendingPosts.isEmpty
              ? const Center(child: Text('No pending posts'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: pendingPosts
                        .map(
                          (post) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: PendingPostRow(post: post),
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

class PendingPostRow extends ConsumerWidget {
  final Post post;
  const PendingPostRow({required this.post, super.key});

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
                  color: post.status == 'approved'
                      ? Colors.green.withOpacity(0.2)
                      : post.status == 'rejected'
                      ? Colors.red.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  post.status ?? 'Pending',
                  style: TextStyle(
                    color: post.status == 'approved'
                        ? Colors.green
                        : post.status == 'rejected'
                        ? Colors.red
                        : Colors.orange,
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

          // Approve/Reject buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  await ref
                      .read(pendingPostsProvider.notifier)
                      .updatePostStatus(post.id, 'rejected');
                },
                child: const Text(
                  'Reject',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () async {
                  await ref
                      .read(pendingPostsProvider.notifier)
                      .updatePostStatus(post.id, 'approved');
                },
                child: const Text(
                  'Approve',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
