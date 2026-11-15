import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_harness.dart';
import 'widget_samples.dart';

/// FR-010, US6 scenario 2: every widget builds from plain values alone.
void main() {
  final samples = plainWidgets();
  for (final entry in samples.entries) {
    testWidgets('${entry.key} builds with no provider scope', (tester) async {
      await pumpWidgetUnderAndSettle(tester, entry.value);
      expect(find.byType(ProviderScope), findsNothing);
      expect(tester.takeException(), isNull);
      expect(find.byWidget(entry.value), findsOneWidget);
    });
  }
}
