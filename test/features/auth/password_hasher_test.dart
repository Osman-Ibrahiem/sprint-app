import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/auth/domain/password_hasher.dart';

void main() {
  test('same password and salt give the same hash', () {
    final salt = PasswordHasher.generateSalt(Random(1));
    expect(
      PasswordHasher.hashWithSalt('Secret123', salt),
      PasswordHasher.hashWithSalt('Secret123', salt),
    );
  });

  test('different salts differ', () {
    final a = PasswordHasher.hash('Secret123');
    final b = PasswordHasher.hash('Secret123');
    expect(a.salt, isNot(b.salt));
    expect(a.hash, isNot(b.hash));
  });

  test('salt is 16 bytes base64', () {
    expect(PasswordHasher.generateSalt().length, 24);
  });

  test('plain password never appears in the output', () {
    final h = PasswordHasher.hash('Secret123');
    expect(h.hash.contains('Secret123'), isFalse);
    expect(h.salt.contains('Secret123'), isFalse);
  });

  test('verify accepts the right password, rejects others', () {
    final h = PasswordHasher.hash('Secret123');
    expect(
      PasswordHasher.verify('Secret123', salt: h.salt, hash: h.hash),
      isTrue,
    );
    expect(
      PasswordHasher.verify('secret123', salt: h.salt, hash: h.hash),
      isFalse,
    );
    expect(
      PasswordHasher.verify('Secret123', salt: h.salt, hash: 'short'),
      isFalse,
    );
  });
}
