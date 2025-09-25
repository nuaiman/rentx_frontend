import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../posts/screens/posts_screen.dart';
import '../notifiers/user_init_notifier.dart';

class UserInitScreen extends ConsumerWidget {
  const UserInitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initState = ref.watch(userInitProvider);

    return initState.when(
      data: (_) {
        // All initial fetches done — can proceed to HomeScreen
        return const PostsScreen();
        // return const AdminHomeScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      ),
      error: (e, st) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // retry
                  ref.invalidate(userInitProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
