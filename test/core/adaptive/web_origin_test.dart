import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/adaptive/web_origin.dart';

void main() {
  test('is null outside the web', () {
    expect(webBaseUrl(), isNull);
  });
}
