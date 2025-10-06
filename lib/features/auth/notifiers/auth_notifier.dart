import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../posts/screens/posts_screen.dart';
import '../api/auth_api.dart';
import '../models/auth.dart';
import '../utils/token_storage.dart';

class AuthNotifier extends AsyncNotifier<Auth?> {
  @override
  Auth? build() {
    return null;
  }

  Future<void> getCurrentUserWithRefresh() async {
    await TokenStorage.initialize();
    try {
      String? refreshToken;
      try {
        refreshToken = await TokenStorage.readRefreshToken();
      } catch (_) {
        refreshToken = null;
      }
      if (refreshToken == null) {
        state = AsyncValue.data(null);
        return;
      }
      final res = await AuthApi.refreshToken(refreshToken);
      state = AsyncValue.data(res);
      if (res.refreshToken != null) {
        await TokenStorage.saveRefreshToken(res.refreshToken!);
      }
    } catch (e, _) {
      state = AsyncValue.data(null);
      await TokenStorage.clearRefreshToken();
    }
  }

  Future<void> authPhone(BuildContext context, String phone) async {
    state = const AsyncValue.loading();
    try {
      final res = await AuthApi.authByPhone(phone);
      if (res.refreshToken != null) {
        await TokenStorage.saveRefreshToken(res.refreshToken!);
      }
      state = AsyncValue.data(res);
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

  Future<void> authEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    state = const AsyncValue.loading();
    try {
      print('Calling AuthApi.authByEmail...');
      print('Email: $email');
      final res = await AuthApi.authByEmail(email, password);
      print('Got response: $res');

      if (res.refreshToken != null) {
        print('Saving refresh token...');
        await TokenStorage.saveRefreshToken(res.refreshToken!);
        print('Refresh token saved.');
      }

      state = AsyncValue.data(res);
      print('State updated, navigating...');

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const PostsScreen()));
    } catch (e, st) {
      print('Caught error: $e\n$st');
      state = AsyncValue.error(e, st);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    }
  }

  Future<void> authWithOAuthEmail(BuildContext context, String email) async {
    state = const AsyncValue.loading();
    try {
      final res = await AuthApi.authOAuthEmailOnly(email);
      if (res.refreshToken != null) {
        await TokenStorage.saveRefreshToken(res.refreshToken!);
      }
      state = AsyncValue.data(res);
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

  Future<void> logout() async {
    await TokenStorage.clearRefreshToken();
    state = AsyncValue.data(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, Auth?>(
  AuthNotifier.new,
);
