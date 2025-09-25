import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/notifiers/auth_notifier.dart';
import '../api/post_api.dart';
import '../models/post.dart';
import 'approved_post_notifier.dart';

class PendingPostsNotifier extends Notifier<List<Post>> {
  @override
  List<Post> build() {
    fetchPendingPosts();
    return [];
  }

  // ──────────────────────────────
  // Admin-only functions
  // ──────────────────────────────

  /// Fetch only pending posts (admin only)
  Future<void> fetchPendingPosts() async {
    final token = ref.read(authProvider).value?.token;
    if (token == null) return;

    try {
      final posts = await PostApi.getPendingPosts(token);
      state = posts;
    } catch (_) {}
  }

  /// Approve or reject a post (admin only)
  Future<void> updatePostStatus(int postId, String status) async {
    final token = ref.read(authProvider).value?.token;
    if (token == null) return;

    try {
      final postIndex = state.indexWhere((p) => p.id == postId);
      if (postIndex == -1) return;

      final post = state[postIndex];

      // Call API to update status
      await PostApi.updatePostStatus(
        postId: postId,
        status: status,
        token: token,
      );

      // Remove from pending posts state
      state = state.where((p) => p.id != postId).toList();

      // If approved, add to approved posts
      if (status == 'approved') {
        final approvedNotifier = ref.read(approvedPostsProvider.notifier);
        approvedNotifier.addApprovedPost(post.copyWith(status: status));
      }
    } catch (e) {
      rethrow;
    }
  }
}

final pendingPostsProvider = NotifierProvider<PendingPostsNotifier, List<Post>>(
  PendingPostsNotifier.new,
);
