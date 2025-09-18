import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/base_url.dart';
import '../models/order.dart';

class OrderApi {
  static Future<List<Order>> getOrders() async {
    final res = await http.get(Uri.parse('$baseUrl/orders'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Order.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch orders');
  }

  static Future<Order> getOrderById(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/orders/$id'));
    if (res.statusCode == 200) {
      return Order.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to fetch order');
  }

  static Future<Order> createOrder(Order order) async {
    final res = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(order.toJson()),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return Order.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to create order');
  }

  static Future<void> deleteOrder(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/orders/$id'));
    if (res.statusCode != 200) {
      throw Exception('Failed to delete order');
    }
  }
}
