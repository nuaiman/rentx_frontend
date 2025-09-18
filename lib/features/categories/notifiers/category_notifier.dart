import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/categories/models/category.dart';
import '../../auth/notifiers/auth_notifier.dart';
import '../api/categories_api.dart';

class CategoriesNotifier extends Notifier<List<Category>> {
  @override
  List<Category> build() {
    fetchCategories();
    return [];
  }

  /// Fetch all categories
  Future<void> fetchCategories() async {
    final cats = await CategoryApi.getAllCategories();
    state = cats;
  }

  /// Get current auth token
  String? _getToken(WidgetRef ref) =>
      ref.read(authProvider).requireValue!.token;

  /// Create a new category
  Future<void> createCategory(String name, WidgetRef ref) async {
    final token = _getToken(ref);
    if (token == null) return;
    final newCategory = await CategoryApi.createCategory(name, token);
    if (newCategory != null) {
      state = [...state, newCategory];
    }
  }

  /// Update an existing category
  Future<void> updateCategory(int id, String name, WidgetRef ref) async {
    final token = _getToken(ref);
    if (token == null) return;
    final updated = await CategoryApi.updateCategory(id, name, token);
    if (updated != null) {
      state = state.map((c) => c.id == id ? updated : c).toList();
    }
  }

  /// Delete a category
  Future<void> deleteCategory(int id, WidgetRef ref) async {
    final token = _getToken(ref);
    if (token == null) return;
    final success = await CategoryApi.deleteCategory(id, token);
    if (success) {
      state = state.where((c) => c.id != id).toList();
    }
  }
}

// -----------------------------------------------------------------------------
// Provider
final categoriesProvider = NotifierProvider<CategoriesNotifier, List<Category>>(
  CategoriesNotifier.new,
);
