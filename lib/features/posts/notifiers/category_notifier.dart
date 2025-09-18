import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../categories/models/category.dart';

class CategoryNotifier extends Notifier<Category?> {
  @override
  Category? build() {
    return null;
  }

  void setCategory(Category category) {
    if (state?.id == category.id) {
      state = null;
    } else {
      state = category;
    }
  }
}

// -----------------------------------------------------------------------------
final categoryProvider = NotifierProvider<CategoryNotifier, Category?>(
  CategoryNotifier.new,
);
