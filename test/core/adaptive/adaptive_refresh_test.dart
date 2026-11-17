import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/adaptive/adaptive_refresh.dart';
import 'package:sprint/core/theme/sprint_theme.dart';

void main() {
  Widget host(TargetPlatform platform, {required Future<void> Function() onRefresh}) {
    return MaterialApp(
      theme: SprintTheme.light.copyWith(platform: platform),
      home: AdaptiveRefresh(
        onRefresh: onRefresh,
        child: ListView(children: const [SizedBox(height: 2000)]),
      ),
    );
  }

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]) {
    testWidgets('$platform uses the platform pull-to-refresh', (tester) async {
      var calls = 0;
      await tester.pumpWidget(host(platform, onRefresh: () async => calls++));
      expect(find.byType(RefreshIndicator), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, 500));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(calls, 1);
    });
  }

  testWidgets('desktop passes the child through', (tester) async {
    await tester.pumpWidget(host(TargetPlatform.windows, onRefresh: () async {}));
    expect(find.byType(RefreshIndicator), findsNothing);
    expect(find.byType(ListView), findsOneWidget);
  });
}
