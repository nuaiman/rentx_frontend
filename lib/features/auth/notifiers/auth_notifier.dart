import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../posts/screens/posts_screen.dart';
import '../api/auth_api.dart';
import '../models/auth.dart';

class AuthNotifier extends AsyncNotifier<Auth?> {
  @override
  Auth? build() {
    return null;
  }

  // Future<void> signup(
  //   BuildContext context,
  //   String phone,
  //   String email,
  //   String password,
  // ) async {
  //   state = const AsyncValue.loading();
  //   try {
  //     final res = await AuthApi.signup(phone, email, password);
  //     state = AsyncValue.data(res);

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Signup successful! Please login.')),
  //     );
  //   } catch (e, st) {
  //     state = AsyncValue.error(e, st);
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Signup failed: $e')));
  //   }
  // }

  Future<void> authEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    state = const AsyncValue.loading();
    try {
      final res = await AuthApi.authByEmail(email, password);
      state = AsyncValue.data(res);

      // Navigate to home
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const PostsScreen()));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    }
  }

  void logout() {
    state = AsyncValue.data(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, Auth?>(
  AuthNotifier.new,
);
