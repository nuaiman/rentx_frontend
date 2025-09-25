import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifiers/category_notifier.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Categories',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: categories.isEmpty
          ? const Center(
              child: Text(
                'No categories yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      childrenPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      title: Text(
                        cat.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      leading: Container(
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.folder,
                          color: Colors.blueAccent,
                          size: 28,
                        ),
                      ),
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.edit, color: Colors.orange),
                          title: const Text(
                            'Edit Category',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          onTap: () async {
                            final newName = await _showInputDialog(
                              context,
                              title: 'Update Category',
                              initialValue: cat.name,
                            );
                            if (newName != null && newName.isNotEmpty) {
                              await ref
                                  .read(categoriesProvider.notifier)
                                  .updateCategory(cat.id, newName, ref);
                            }
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.delete, color: Colors.red),
                          title: const Text(
                            'Delete Category',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                            ),
                          ),
                          onTap: () async {
                            final confirm = await _showConfirmDialog(
                              context,
                              'Delete Category "${cat.name}"?',
                            );
                            if (confirm) {
                              await ref
                                  .read(categoriesProvider.notifier)
                                  .deleteCategory(cat.id, ref);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final name = await _showInputDialog(context, title: 'Add Category');
          if (name != null && name.isNotEmpty) {
            await ref
                .read(categoriesProvider.notifier)
                .createCategory(name, ref);
          }
        },
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Category',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ────────────── Dialogs ──────────────

  static Future<String?> _showInputDialog(
    BuildContext context, {
    required String title,
    String initialValue = '',
  }) async {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  static Future<bool> _showConfirmDialog(
    BuildContext context,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
