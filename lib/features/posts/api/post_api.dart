import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/core/constants/base_url.dart';
import '../models/post.dart';

class PostApi {
  // Upload multiple images for a specific post
  static Future<List<String>> uploadPostImages({
    required int postId,
    required List<File?> imageFiles,
    required List<Uint8List?> imageBytes,
    required String token,
  }) async {
    final uri = Uri.parse('$baseUrl/upload/post-image');
    final request = http.MultipartRequest('POST', uri)
      ..fields['postId'] = postId.toString()
      ..headers['Authorization'] = 'Bearer $token';

    for (int i = 0; i < imageFiles.length; i++) {
      if ((kIsWeb && imageBytes[i] != null) ||
          (!kIsWeb && imageFiles[i] != null)) {
        if (kIsWeb && imageBytes[i] != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'files',
              imageBytes[i]!,
              filename: 'image_$i.png',
            ),
          );
        } else if (!kIsWeb && imageFiles[i] != null) {
          request.files.add(
            await http.MultipartFile.fromPath('files', imageFiles[i]!.path),
          );
        }
      }
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(body);
      return (data['urls'] as List).map((e) => e.toString()).toList();
    } else {
      throw Exception('Failed to upload images: $body');
    }
  }

  static Future<Post> createPost(Post post, String token) async {
    final res = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(post.toJson()),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return Post.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to create post');
  }

  static Future<List<Post>> getApprovedPosts() async {
    final res = await http.get(Uri.parse('$baseUrl/approved-posts'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Post.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch posts');
  }

  static Future<void> deletePost(int id, String token) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/posts/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Failed to delete post');
  }

  static Future<Post> updatePost(Post post, String token) async {
    final res = await http.put(
      Uri.parse('$baseUrl/posts/${post.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(post.toJson()),
    );
    if (res.statusCode == 200) return Post.fromJson(jsonDecode(res.body));
    throw Exception('Failed to update post');
  }

  /// Get a single post by ID (public)
  static Future<Post> getPostById(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/posts/$id'));
    if (res.statusCode == 200) {
      return Post.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to fetch post');
  }

  /// Get all pending posts (admin only)
  static Future<List<Post>> getPendingPosts(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/posts/pending'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Post.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch pending posts');
  }

  /// Approve or Reject a post (admin only)
  static Future<void> updatePostStatus({
    required int postId,
    required String status, // 'approved' or 'rejected'
    required String token,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/posts/$postId/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': status}),
    );

    if (res.statusCode != 200) {
      // surface backend message if any
      try {
        final body = jsonDecode(res.body);
        throw Exception(body['message'] ?? 'Failed to update status');
      } catch (_) {
        throw Exception('Failed to update status');
      }
    }
  }

  /// Get all posts (admin only)
  // static Future<List<Post>> getAllPosts(String token) async {
  //   final res = await http.get(
  //     Uri.parse('$baseUrl/posts/all'),
  //     headers: {'Authorization': 'Bearer $token'},
  //   );
  //   if (res.statusCode == 200) {
  //     final data = jsonDecode(res.body) as List;
  //     return data.map((e) => Post.fromJson(e)).toList();
  //   }
  //   throw Exception('Failed to fetch all posts');
  // }
}
