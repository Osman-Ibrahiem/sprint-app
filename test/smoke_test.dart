import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprint/main.dart' as app;

import 'helpers/pump_app.dart';

void main() {
  testWidgets('app starts in Arabic RTL inside a ProviderScope', (tester) async {
    SharedPreferences.setMockInitialValues({});
    setWindow(tester);
    await tester.runAsync(app.main);
    await tester.pumpAndSettle();
    expect(find.byType(ProviderScope), findsOneWidget);
    final home = find.text(ar.homeTitle);
    expect(home, findsOneWidget);
    final ctx = tester.element(home);
    expect(Directionality.of(ctx), TextDirection.rtl);
  });
}
