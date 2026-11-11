import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/window/window_size.dart';

void main() {
  final cases = <double, WindowSize>{
    320: WindowSize.compact,
    599: WindowSize.compact,
    600: WindowSize.medium,
    839: WindowSize.medium,
    840: WindowSize.expanded,
    1199: WindowSize.expanded,
    1200: WindowSize.large,
    1920: WindowSize.large,
  };

  cases.forEach((width, expected) {
    test('width $width is $expected', () {
      expect(WindowSize.fromWidth(width), expected);
    });
  });

  testWidgets('WindowSize.of reads the window width from MediaQuery',
      (tester) async {
    late WindowSize seen;
    for (final entry in cases.entries) {
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(size: Size(entry.key, 800)),
          child: Builder(
            builder: (context) {
              seen = WindowSize.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(seen, entry.value, reason: 'width ${entry.key}');
    }
  });
}
