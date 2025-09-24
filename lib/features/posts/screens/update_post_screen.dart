import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post.dart';
import '../notifiers/post_notifier.dart';

class UpdatePostScreen extends ConsumerStatefulWidget {
  final Post post;
  const UpdatePostScreen({super.key, required this.post});

  @override
  ConsumerState<UpdatePostScreen> createState() => _UpdatePostScreenState();
}

class _UpdatePostScreenState extends ConsumerState<UpdatePostScreen> {
  final _formKey = GlobalKey<FormState>();

  // Changed all `late` fields to nullable
  int? categoryId;
  String? name;
  String? address;
  String? description;
  double? dailyPrice;
  double? weeklyPrice;
  double? monthlyPrice;

  // Lists for images
  List<String>? serverImages; // existing URLs
  List<PlatformFile>? newPickedFiles; // newly picked files

  @override
  void initState() {
    super.initState();
    categoryId = widget.post.categoryId;
    name = widget.post.name;
    address = widget.post.address;
    description = widget.post.description;
    dailyPrice = widget.post.dailyPrice;
    weeklyPrice = widget.post.weeklyPrice;
    monthlyPrice = widget.post.monthlyPrice;

    serverImages = List.from(widget.post.imageUrls);
    newPickedFiles = [];
  }

  Future<void> pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      withData: true,
    );
    if (result != null) {
      setState(() {
        newPickedFiles!.addAll(result.files);
      });
    }
  }

  void removeServerImage(int index) {
    setState(() {
      serverImages!.removeAt(index);
    });
  }

  void removeNewImage(int index) {
    setState(() {
      newPickedFiles!.removeAt(index);
    });
  }

  void submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final imageFiles = newPickedFiles!
        .map((f) => f.path != null ? File(f.path!) : null)
        .toList();
    final imageBytes = newPickedFiles!.map((f) => f.bytes).toList();

    final updatedPost = widget.post.copyWith(
      categoryId: categoryId!,
      name: name!,
      address: address!,
      description: description!,
      dailyPrice: dailyPrice!,
      weeklyPrice: weeklyPrice!,
      monthlyPrice: monthlyPrice!,
      imageUrls: serverImages!,
      imageFiles: imageFiles,
      imageBytes: imageBytes,
    );

    await ref.read(postsProvider.notifier).updatePost(updatedPost);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post updated successfully!')),
      );
      Navigator.pop(context);
    }
  }

  Widget buildServerImage(int index) {
    final url = serverImages![index];
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: Image.network(url, fit: BoxFit.cover),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => removeServerImage(index),
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

  Widget buildNewImage(int index) {
    final file = newPickedFiles![index];
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: Image.memory(file.bytes!, fit: BoxFit.cover),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => removeNewImage(index),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Update Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Name'),
                onSaved: (v) => name = v ?? '',
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                initialValue: address,
                decoration: const InputDecoration(labelText: 'Address'),
                onSaved: (v) => address = v ?? '',
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (v) => description = v ?? '',
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                initialValue: dailyPrice.toString(),
                decoration: const InputDecoration(labelText: 'Daily Price'),
                keyboardType: TextInputType.number,
                onSaved: (v) => dailyPrice = double.tryParse(v ?? '0') ?? 0,
              ),
              TextFormField(
                initialValue: weeklyPrice.toString(),
                decoration: const InputDecoration(labelText: 'Weekly Price'),
                keyboardType: TextInputType.number,
                onSaved: (v) => weeklyPrice = double.tryParse(v ?? '0') ?? 0,
              ),
              TextFormField(
                initialValue: monthlyPrice.toString(),
                decoration: const InputDecoration(labelText: 'Monthly Price'),
                keyboardType: TextInputType.number,
                onSaved: (v) => monthlyPrice = double.tryParse(v ?? '0') ?? 0,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: pickImages,
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Add Images'),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${serverImages!.length + newPickedFiles!.length} image(s) selected',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                children: [
                  ...List.generate(
                    serverImages!.length,
                    (i) => buildServerImage(i),
                  ),
                  ...List.generate(
                    newPickedFiles!.length,
                    (i) => buildNewImage(i),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: submit,
                child: const Text('Update Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
