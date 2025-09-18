import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/base_url.dart';
import '../models/auth.dart';

class AuthApi {
  // static Future<Auth> signup(
  //   String phone,
  //   String email,
  //   String password,
  // ) async {
  //   final res = await http.post(
  //     Uri.parse('$baseUrl/signup'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({'phone': phone, 'email': email, 'password': password}),
  //   );

  //   if (res.statusCode == 201) {
  //     return Auth.fromJson(jsonDecode(res.body));
  //   } else {
  //     throw Exception('Signup failed: ${res.body}');
  //   }
  // }

  static Future<Auth> authByEmail(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth-email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode == 200) {
      return Auth.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Login failed: ${res.body}');
    }
  }
}
