import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../categories/models/category.dart';
import '../notifiers/category_notifier.dart';

class CategoryButton extends ConsumerWidget {
  final Category category;
  final VoidCallback? onTap;

  const CategoryButton({super.key, required this.category, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(categoryProvider);
    final isSelected = selectedCategory?.id == category.id;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap:
            onTap ??
            () {
              ref.read(categoryProvider.notifier).setCategory(category);
            },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            category.name,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
