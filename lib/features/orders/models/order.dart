class Order {
  final int id;
  final int userId;
  final int postId;
  final String dateTime;

  Order({
    required this.id,
    required this.userId,
    required this.postId,
    required this.dateTime,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['userId'],
      postId: json['postId'],
      dateTime: json['dateTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'postId': postId};
  }

  Order copyWith({int? id, int? userId, int? postId, String? dateTime}) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      postId: postId ?? this.postId,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  @override
  String toString() {
    return 'Order(id: $id, userId: $userId, postId: $postId, dateTime: $dateTime)';
  }
}
