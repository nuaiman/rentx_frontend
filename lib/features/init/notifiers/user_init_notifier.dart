import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/notifiers/auth_notifier.dart';
import '../../categories/notifiers/category_notifier.dart';
import '../../posts/notifiers/approved_post_notifier.dart';

class UserInitNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    await _initAll();
  }

  Future<void> _initAll() async {
    // First, restore user session if possible
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.getCurrentUserWithRefresh();

    // Then start fetching other data in parallel
    final categoriesNotifier = ref.read(categoriesProvider.notifier);
    final postsNotifier = ref.read(approvedPostsProvider.notifier);

    await Future.wait([
      categoriesNotifier.fetchCategories().catchError((e) => null),
      postsNotifier.fetchApprovedPosts().catchError((e) => null),
    ]);
  }
}

// -----------------------------------------------------------------------------
final userInitProvider = AsyncNotifierProvider<UserInitNotifier, void>(
  UserInitNotifier.new,
);
