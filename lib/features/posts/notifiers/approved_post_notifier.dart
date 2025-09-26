import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/notifiers/auth_notifier.dart';
import '../api/post_api.dart';
import '../models/post.dart';

class ApprovedPostsNotifier extends Notifier<List<Post>> {
  @override
  List<Post> build() {
    // Default: load public posts
    fetchApprovedPosts();
    return [];
  }

  // ──────────────────────────────
  // Normal user functions
  // ──────────────────────────────

  /// Fetch public posts
  Future<void> fetchApprovedPosts() async {
    try {
      final posts = await PostApi.getApprovedPosts();
      state = posts;
    } catch (_) {}
  }

  /// Create a new post (normal user)
  Future<Post> createPost(Post post) async {
    final token = ref.read(authProvider).value?.token;
    if (token == null) throw Exception("No token");

    final newPost = await PostApi.createPost(
      post.copyWith(imageFiles: [], imageBytes: []),
      token,
    );

    final uploadedUrls = await PostApi.uploadPostImages(
      postId: newPost.id,
      imageFiles: post.imageFiles,
      imageBytes: post.imageBytes,
      token: token,
    );

    final postToUpdate = newPost.copyWith(
      imageUrls: uploadedUrls,
      imageFiles: [],
      imageBytes: [],
      // void func upload the id and set it as path for the media. For example /storage/posts/1/images
    );

    final updatedPost = await PostApi.updatePost(postToUpdate, token);

    // Only add to state if approved
    if (updatedPost.status == 'approved') {
      state = [...state, updatedPost];
    }

    return updatedPost;
  }

  /// Update an existing post (normal user)
  Future<void> updatePost(Post post) async {
    final token = ref.read(authProvider).value?.token;
    if (token == null) return;

    try {
      final uploadedUrls = await PostApi.uploadPostImages(
        postId: post.id,
        imageFiles: post.imageFiles,
        imageBytes: post.imageBytes,
        token: token,
      );

      final postToSend = post.copyWith(
        imageUrls: uploadedUrls.isNotEmpty ? uploadedUrls : post.imageUrls,
        imageFiles: List.filled(post.imageFiles.length, null),
        imageBytes: List.filled(post.imageBytes.length, null),
      );

      final updatedPost = await PostApi.updatePost(postToSend, token);

      final index = state.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        final newState = [...state];
        newState[index] = updatedPost;
        state = newState;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a post
  Future<void> deletePost(int id) async {
    final token = ref.read(authProvider).value?.token;
    if (token == null) return;

    try {
      await PostApi.deletePost(id, token);
      state = state.where((p) => p.id != id).toList();
    } catch (_) {}
  }

  /// Get a single approved post by ID
  Future<Post?> getPostById(int id) async {
    try {
      // First, check if the post is already in state
      Post? existingPost;
      try {
        existingPost = state.firstWhere((p) => p.id == id);
      } catch (_) {
        existingPost = null;
      }
      if (existingPost != null) return existingPost;
      // If not, fetch from API
      final post = await PostApi.getPostById(id);
      // Only add to state if approved
      if (post.status == 'approved') {
        state = [...state, post];
      }
      return post;
    } catch (_) {
      return null;
    }
  }

  /// Add a new post to approved list (called after approval)
  void addApprovedPost(Post post) {
    state = [...state, post];
  }
}

final approvedPostsProvider =
    NotifierProvider<ApprovedPostsNotifier, List<Post>>(
      ApprovedPostsNotifier.new,
    );
