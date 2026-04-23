import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Password hashing helpers for the local backend.
///
/// IMPORTANT: This uses SHA-256 with a per-user random salt. SHA-256 is a
/// fast hash — on a rooted device an attacker with the SharedPreferences
/// blob could brute-force weak passwords. Acceptable for a local demo APK.
/// A PBKDF2/Argon2 upgrade is a future enhancement.
class PasswordHasher {
  PasswordHasher._();

  static final Random _rng = Random.secure();

  /// Generates a fresh base64-encoded 16-byte salt.
  static String newSalt() {
    final bytes = Uint8List(16);
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = _rng.nextInt(256);
    }
    return base64Encode(bytes);
  }

  /// Returns `base64(sha256(salt_bytes || utf8(password)))`.
  static String hash({required String password, required String saltBase64}) {
    final saltBytes = base64Decode(saltBase64);
    final pwBytes = utf8.encode(password);
    final combined = Uint8List(saltBytes.length + pwBytes.length)
      ..setRange(0, saltBytes.length, saltBytes)
      ..setRange(saltBytes.length, saltBytes.length + pwBytes.length, pwBytes);
    final digest = sha256.convert(combined);
    return base64Encode(digest.bytes);
  }

  /// Constant-time string equality for hash comparison.
  static bool verify({
    required String password,
    required String saltBase64,
    required String expectedHashBase64,
  }) {
    final actual = hash(password: password, saltBase64: saltBase64);
    if (actual.length != expectedHashBase64.length) return false;
    var diff = 0;
    for (var i = 0; i < actual.length; i++) {
      diff |= actual.codeUnitAt(i) ^ expectedHashBase64.codeUnitAt(i);
    }
    return diff == 0;
  }
}
