import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/order_api.dart';
import '../models/order.dart';

class OrdersNotifier extends Notifier<List<Order>> {
  @override
  List<Order> build() {
    fetchOrders();
    return [];
  }

  Future<void> fetchOrders() async {
    try {
      final orders = await OrderApi.getOrders();
      state = orders;
    } catch (_) {}
  }

  Future<void> createOrder(Order order) async {
    try {
      final newOrder = await OrderApi.createOrder(order);
      state = [...state, newOrder];
    } catch (_) {}
  }

  Future<void> deleteOrder(int id) async {
    try {
      await OrderApi.deleteOrder(id);
      state = state.where((o) => o.id != id).toList();
    } catch (_) {}
  }
}

final ordersProvider = NotifierProvider<OrdersNotifier, List<Order>>(
  OrdersNotifier.new,
);
