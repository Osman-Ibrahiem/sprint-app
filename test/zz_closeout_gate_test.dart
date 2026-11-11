import 'package:flutter_test/flutter_test.dart';

// Deliberately failing, to prove the required `build` check blocks a merge
// (SC-010). Reverted in the next commit of the same PR.
void main() {
  test('merge gate: this test fails on purpose', () {
    expect(1 + 1, 3);
  });
}
