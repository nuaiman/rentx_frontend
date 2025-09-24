import 'dart:io';
import 'dart:typed_data';
import '../../../core/constants/base_url.dart';

class Post {
  final int id;
  final int userId;
  final int categoryId;
  final String name;
  final String address;
  final String description;
  final double dailyPrice;
  final double weeklyPrice;
  final double monthlyPrice;

  // Server image URLs
  final List<String> imageUrls;

  // Local files / bytes for upload (frontend only)
  final List<File?> imageFiles;
  final List<Uint8List?> imageBytes;

  // Nullable status
  final String? status;

  Post({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.name,
    required this.address,
    required this.description,
    required this.dailyPrice,
    required this.weeklyPrice,
    required this.monthlyPrice,
    required this.imageUrls,
    required this.imageFiles,
    required this.imageBytes,
    this.status,
  });

  Post copyWith({
    int? id,
    int? userId,
    int? categoryId,
    String? name,
    String? address,
    String? description,
    double? dailyPrice,
    double? weeklyPrice,
    double? monthlyPrice,
    List<String>? imageUrls,
    List<File?>? imageFiles,
    List<Uint8List?>? imageBytes,
    String? status,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      address: address ?? this.address,
      description: description ?? this.description,
      dailyPrice: dailyPrice ?? this.dailyPrice,
      weeklyPrice: weeklyPrice ?? this.weeklyPrice,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      imageUrls: imageUrls ?? this.imageUrls,
      imageFiles: imageFiles ?? this.imageFiles,
      imageBytes: imageBytes ?? this.imageBytes,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'categoryId': categoryId,
    'name': name,
    'address': address,
    'description': description,
    'dailyPrice': dailyPrice,
    'weeklyPrice': weeklyPrice,
    'monthlyPrice': monthlyPrice,
    'imageUrls': imageUrls,
    'status': status,
  };

  factory Post.fromJson(Map<String, dynamic> json) {
    List<String> urls = [];
    if (json['imageUrls'] != null && json['imageUrls'] is List) {
      urls = List<String>.from(json['imageUrls'].map((u) => '$baseUrl$u'));
    }

    return Post(
      id: json['id'],
      userId: json['userId'],
      categoryId: json['categoryId'],
      name: json['name'],
      address: json['address'],
      description: json['description'],
      dailyPrice: (json['dailyPrice'] as num).toDouble(),
      weeklyPrice: (json['weeklyPrice'] as num?)?.toDouble() ?? 0,
      monthlyPrice: (json['monthlyPrice'] as num?)?.toDouble() ?? 0,
      imageUrls: urls,
      imageFiles: List.filled(urls.length, null),
      imageBytes: List.filled(urls.length, null),
      status: json['status'] as String?,
    );
  }

  @override
  String toString() {
    return 'Post(id: $id, name: $name, status: $status, images: $imageUrls)';
  }
}
