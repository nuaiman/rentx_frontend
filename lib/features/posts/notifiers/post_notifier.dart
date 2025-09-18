import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/notifiers/auth_notifier.dart';
import '../api/post_api.dart';
import '../models/post.dart';

class PostsNotifier extends Notifier<List<Post>> {
  @override
  List<Post> build() {
    fetchPosts();
    return [];
  }

  Future<void> fetchPosts() async {
    try {
      final posts = await PostApi.getPosts();
      state = posts;
    } catch (_) {}
  }

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
    );

    final updatedPost = await PostApi.updatePost(postToUpdate, token);

    state = [...state, updatedPost];

    return updatedPost;
  }

  Future<void> updatePost(Post post) async {
    final token = ref.read(authProvider).value?.token;
    if (token == null) return;

    try {
      // Upload new images if any
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

  Future<void> deletePost(int id) async {
    final token = ref.read(authProvider).value?.token;
    if (token == null) return;

    try {
      await PostApi.deletePost(id, token);
      state = state.where((p) => p.id != id).toList();
    } catch (_) {}
  }
}

final postsProvider = NotifierProvider<PostsNotifier, List<Post>>(
  PostsNotifier.new,
);
