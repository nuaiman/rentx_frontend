import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../orders/notifiers/orders_notifier.dart';
import '../../posts/notifiers/pending_post_notifier.dart';

class AdminInitNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    await _initAll();
  }

  Future<void> _initAll() async {
    // First, restore user session if possible
    // final authNotifier = ref.read(authProvider.notifier);
    // await authNotifier.getCurrentUserWithRefresh();

    // Then start fetching other data in parallel
    final pendingPostsNotifier = ref.read(pendingPostsProvider.notifier);
    final ordersNotifier = ref.read(ordersProvider.notifier);

    await Future.wait([
      pendingPostsNotifier.fetchPendingPosts().catchError((e) => null),
      ordersNotifier.fetchOrders().catchError((e) => null),
    ]);
  }
}

// -----------------------------------------------------------------------------
final adminInitProvider = AsyncNotifierProvider<AdminInitNotifier, void>(
  AdminInitNotifier.new,
);
