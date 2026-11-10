import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/main.dart' as app;

void main() {
  testWidgets('app starts in Arabic RTL inside a ProviderScope', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    expect(find.byType(ProviderScope), findsOneWidget);
    expect(find.text('سبرنت'), findsOneWidget);
    final ctx = tester.element(find.text('سبرنت'));
    expect(Directionality.of(ctx), TextDirection.rtl);
  });
}
