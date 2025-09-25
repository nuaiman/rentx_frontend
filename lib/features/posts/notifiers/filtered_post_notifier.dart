import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../categories/models/category.dart';
import '../models/post.dart';
import 'category_notifier.dart';
import 'approved_post_notifier.dart';
import 'search_notifier.dart';

class FilteredPostsNotifier extends Notifier<List<Post>> {
  @override
  List<Post> build() {
    final allItems = ref.watch(approvedPostsProvider);
    final selectedCategory = ref.watch(categoryProvider);
    final searchQuery = ref.watch(searchProvider);

    return _filterItems(allItems, selectedCategory, searchQuery);
  }

  List<Post> _filterItems(List<Post> items, Category? category, String query) {
    return items.where((item) {
      final matchesCategory = category == null
          ? true
          : item.categoryId == category.id;
      final matchesQuery = item.name.toLowerCase().contains(
        query.toLowerCase(),
      );
      return matchesCategory && matchesQuery;
    }).toList();
  }
}

// -----------------------------------------------------------------------------
final filteredItemsProvider =
    NotifierProvider<FilteredPostsNotifier, List<Post>>(
      FilteredPostsNotifier.new,
    );
