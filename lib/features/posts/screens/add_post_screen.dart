import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/notifiers/auth_notifier.dart';
import '../../categories/notifiers/category_notifier.dart';
import '../models/post.dart';
import '../notifiers/post_notifier.dart';

class AddPostScreen extends ConsumerStatefulWidget {
  const AddPostScreen({super.key});

  @override
  ConsumerState<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends ConsumerState<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedCategoryId;
  String _name = '';
  String _address = '';
  String _description = '';
  double _dailyPrice = 0;
  double _weeklyPrice = 0;
  double _monthlyPrice = 0;

  final List<PlatformFile> _pickedFiles = [];

  // Pick multiple images
  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      withData: true,
    );
    if (result != null) {
      setState(() {
        _pickedFiles.addAll(result.files);
      });
    }
  }

  // Remove selected image
  void _removeImage(int index) {
    setState(() {
      _pickedFiles.removeAt(index);
    });
  }

  // Submit form
  Future<void> _submit(int userId) async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) {
      return;
    }

    _formKey.currentState!.save();

    final imageFiles = _pickedFiles
        .map((f) => f.path != null ? File(f.path!) : null)
        .toList();
    final imageBytes = _pickedFiles.map((f) => f.bytes).toList();

    final post = Post(
      id: 0,
      userId: userId,
      categoryId: _selectedCategoryId!,
      name: _name,
      address: _address,
      description: _description,
      dailyPrice: _dailyPrice,
      weeklyPrice: _weeklyPrice,
      monthlyPrice: _monthlyPrice,
      imageUrls: [],
      imageFiles: imageFiles,
      imageBytes: imageBytes,
    );

    try {
      await ref.read(postsProvider.notifier).createPost(post);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create post: $e')));
    }
  }

  // Preview selected image
  Widget _buildImagePreview(int index) {
    final file = _pickedFiles[index];
    if (file.bytes == null) return const SizedBox();
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(file.bytes!, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: const CircleAvatar(
              radius: 10,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authProvider);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Post')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category dropdown
                  DropdownButtonFormField<int>(
                    initialValue:
                        _selectedCategoryId ??
                        (categories.isNotEmpty ? categories[0].id : null),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: categories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedCategoryId = val),
                    validator: (val) =>
                        val == null ? 'Please select a category' : null,
                  ),

                  // Name
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSaved: (v) => _name = v ?? '',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  // Address
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSaved: (v) => _address = v ?? '',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  // Description
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSaved: (v) => _description = v ?? '',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),

                  // Prices
                  Row(
                    spacing: 16,
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Daily Price',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onSaved: (v) =>
                              _dailyPrice = double.tryParse(v ?? '0') ?? 0,
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Weekly Price',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onSaved: (v) =>
                              _weeklyPrice = double.tryParse(v ?? '0') ?? 0,
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Monthly Price',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onSaved: (v) =>
                              _monthlyPrice = double.tryParse(v ?? '0') ?? 0,
                        ),
                      ),
                    ],
                  ),

                  // Image picker
                  Row(
                    children: [
                      CupertinoButton.filled(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        onPressed: _pickImages,
                        child: const Text('Add Images'),
                      ),
                      const SizedBox(width: 12),
                      Text('${_pickedFiles.length} image(s) selected'),
                    ],
                  ),
                  Wrap(
                    children: List.generate(
                      _pickedFiles.length,
                      (i) => _buildImagePreview(i),
                    ),
                  ),

                  // Submit
                  Align(
                    alignment: Alignment.centerRight,
                    child: CupertinoButton.filled(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 10,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      onPressed: () => _submit(auth.value!.id!),
                      child: const Text('Create Post'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
