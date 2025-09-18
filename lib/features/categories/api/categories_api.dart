import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/constants/base_url.dart';
import 'package:frontend/features/categories/models/category.dart';

class CategoryApi {
  // ---------- Fetch all categories ----------
  static Future<List<Category>> getAllCategories() async {
    final res = await http.get(
      Uri.parse('$baseUrl/category'),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode == 200) {
      try {
        final data = jsonDecode(res.body) as List;
        return data.map((e) => Category.fromJson(e)).toList();
      } catch (e) {
        return [];
      }
    } else {
      return [];
    }
  }

  /// Create a new category
  static Future<Category?> createCategory(String name, String token) async {
    final res = await http.post(
      Uri.parse('$baseUrl/category'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name}),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return Category.fromJson(jsonDecode(res.body));
    }
    return null;
  }

  /// Update a category
  static Future<Category?> updateCategory(
    int id,
    String name,
    String token,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/category/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name}),
    );

    if (res.statusCode == 200) {
      return Category.fromJson(jsonDecode(res.body));
    }
    return null;
  }

  /// Delete a category
  static Future<bool> deleteCategory(int id, String token) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/category/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return res.statusCode == 200;
  }
}
