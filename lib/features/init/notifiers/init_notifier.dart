import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/notifiers/auth_notifier.dart';
import '../../categories/notifiers/category_notifier.dart';
import '../../orders/notifiers/orders_notifier.dart';
import '../../posts/notifiers/post_notifier.dart';

class InitNotifier extends AsyncNotifier<void> {
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
    final postsNotifier = ref.read(postsProvider.notifier);
    final ordersNotifier = ref.read(ordersProvider.notifier);

    await Future.wait([
      categoriesNotifier.fetchCategories().catchError((e) => null),
      postsNotifier.fetchPosts().catchError((e) => null),
      ordersNotifier.fetchOrders().catchError((e) => null),
    ]);
  }
}

// -----------------------------------------------------------------------------
final initProvider = AsyncNotifierProvider<InitNotifier, void>(
  InitNotifier.new,
);
