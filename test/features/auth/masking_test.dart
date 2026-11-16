import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/auth/domain/masking.dart';

void main() {
  test('phone keeps the first three and last three digits', () {
    expect(maskPhone('01000000001'), '010•••••001');
    expect(maskPhone('123'), '•••');
  });

  test('email keeps its first letter and its domain', () {
    expect(maskEmail('mona@example.test'), 'm•••@example.test');
    expect(maskEmail('bad'), '•••');
  });
}
