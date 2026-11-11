import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/l10n/ltr_isolate.dart';

void main() {
  test('ltrIsolate wraps text in LRI and PDI so codes keep their order', () {
    expect(ltrIsolate('SP-1042'), '\u2066SP-1042\u2069');
  });

  testWidgets('LtrIsolate forces left-to-right inside Arabic', (tester) async {
    late TextDirection seen;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: LtrIsolate(
          child: Builder(
            builder: (context) {
              seen = Directionality.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    expect(seen, TextDirection.ltr);
  });
}
