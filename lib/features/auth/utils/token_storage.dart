import 'package:flutter/foundation.dart';
import 'package:simple_secure_storage/simple_secure_storage.dart';

class TokenStorage {
  static const _refreshTokenKey = 'refreshToken';
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    if (kIsWeb) {
      await SimpleSecureStorage.initialize(
        WebInitializationOptions(
          keyPassword: 'A8d9F#2lQp!z7x',
          encryptionSalt: 'S4rT!q2Lm9e',
        ),
      );
    } else {
      await SimpleSecureStorage.initialize();
    }

    _initialized = true;
  }

  static Future<void> saveRefreshToken(String token) async {
    await initialize();
    await SimpleSecureStorage.write(_refreshTokenKey, token);
  }

  static Future<String?> readRefreshToken() async {
    await initialize();
    return await SimpleSecureStorage.read(_refreshTokenKey);
  }

  static Future<void> clearRefreshToken() async {
    await initialize();
    await SimpleSecureStorage.delete(_refreshTokenKey);
  }
}
