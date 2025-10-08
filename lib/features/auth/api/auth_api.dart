import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/base_url.dart';
import '../models/auth.dart';

class AuthApi {
  static Future<Auth> refreshToken(String refreshToken) async {
    final res = await http.post(
      Uri.parse('$baseUrl/refresh-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (res.statusCode == 200) {
      return Auth.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Refresh token failed: ${res.body}');
    }
  }

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

  static Future<Auth> authByPhone(String phone) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth-phone'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );

    if (res.statusCode == 200) {
      return Auth.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Login failed: ${res.body}');
    }
  }

  static Future<Auth> googleAuth({
    required String idToken,
    required String accessToken,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth-google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken, 'accessToken': accessToken}),
    );

    if (res.statusCode == 200) {
      return Auth.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('OAuth login failed: ${res.body}');
    }
  }
}
