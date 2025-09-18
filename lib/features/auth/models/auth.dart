class Auth {
  final String message;
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? image;
  final String? token;
  final String? role;

  Auth({
    required this.message,
    this.id,
    this.name,
    this.email,
    this.phone,
    this.image,
    this.token,
    this.role,
  });

  factory Auth.fromJson(Map<String, dynamic> json) => Auth(
    message: json['message'] ?? '',
    id: json['id'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    image: json['image'],
    token: json['token'],
    role: json['role'],
  );

  Map<String, dynamic> toJson() => {
    'message': message,
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'image': image,
    'token': token,
    'role': role,
  };
}
