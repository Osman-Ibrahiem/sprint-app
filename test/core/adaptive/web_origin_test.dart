import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/adaptive/web_origin.dart';

void main() {
  test('the base is the origin plus the page directory', () {
    expect(
      webBaseOf(Uri.parse('https://host/sprint-app/')),
      'https://host/sprint-app/',
    );
    expect(
      webBaseOf(Uri.parse('https://host/sprint-app/index.html')),
      'https://host/sprint-app/',
    );
    expect(
      webBaseOf(Uri.parse('https://host/sprint-app/#/facilities/f-pool')),
      'https://host/sprint-app/',
    );
    expect(webBaseOf(Uri.parse('https://host/')), 'https://host/');
  });
}
