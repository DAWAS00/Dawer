import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStore {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'firebase_jwt';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
