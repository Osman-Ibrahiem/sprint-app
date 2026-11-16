import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// A salt and the hash made from it, both base64 (research R3).
class PasswordHash {
  const PasswordHash({required this.salt, required this.hash});
  final String salt;
  final String hash;
}

/// Iterated SHA-256 with a random salt. Enough for a fake repository; the
/// real backend uses its provider's hashing.
abstract final class PasswordHasher {
  static const int saltLength = 16;
  static const int iterations = 10000;

  /// New random salt, base64.
  static String generateSalt([Random? random]) {
    final r = random ?? Random.secure();
    return base64Encode(
      Uint8List.fromList(List<int>.generate(saltLength, (_) => r.nextInt(256))),
    );
  }

  /// `SHA-256(salt + password)` iterated [iterations] times, base64.
  static String hashWithSalt(String password, String salt) {
    var digest = sha256.convert([
      ...base64Decode(salt),
      ...utf8.encode(password),
    ]).bytes;
    for (var i = 1; i < iterations; i++) {
      digest = sha256.convert(digest).bytes;
    }
    return base64Encode(digest);
  }

  /// Hashes with a fresh salt.
  static PasswordHash hash(String password, {Random? random}) {
    final salt = generateSalt(random);
    return PasswordHash(salt: salt, hash: hashWithSalt(password, salt));
  }

  /// Constant-time comparison.
  static bool verify(
    String password, {
    required String salt,
    required String hash,
  }) {
    final a = utf8.encode(hashWithSalt(password, salt));
    final b = utf8.encode(hash);
    var diff = a.length ^ b.length;
    final n = min(a.length, b.length);
    for (var i = 0; i < n; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
