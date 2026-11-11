import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/adaptive/adaptive_loader.dart';
import 'package:sprint/core/adaptive/adaptive_switch.dart';

import '../../helpers/adaptive_harness.dart';

void main() {
  testWidgets('switch uses the platform look and has a spoken label',
      (tester) async {
    final platform = debugDefaultTargetPlatformOverride!;
    final handle = tester.ensureSemantics();
    var value = false;
    await pumpHarness(
      tester,
      (_) => StatefulBuilder(
        builder: (context, setState) => AdaptiveSwitch(
          value: value,
          onChanged: (v) => setState(() => value = v),
          semanticLabel: 'تفعيل التذكيرات',
        ),
      ),
    );

    if (isApple(platform)) {
      expect(find.byType(CupertinoSwitch), findsOneWidget);
      expect(find.byType(Switch), findsNothing);
    } else {
      expect(find.byType(Switch), findsOneWidget);
      expect(find.byType(CupertinoSwitch), findsNothing);
    }
    expect(find.bySemanticsLabel('تفعيل التذكيرات'), findsWidgets);

    // Target is at least 48 dp each way.
    final size = tester.getSize(find.byType(AdaptiveSwitch));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));

    await tester.tap(find.byType(AdaptiveSwitch));
    await tester.pumpAndSettle();
    expect(value, isTrue);
    handle.dispose();
  }, variant: allPlatforms);

  testWidgets('loader uses the platform look and has a spoken label',
      (tester) async {
    final platform = debugDefaultTargetPlatformOverride!;
    final handle = tester.ensureSemantics();
    await pumpHarness(
      tester,
      (_) => const AdaptiveLoader(semanticLabel: 'جاري التحميل'),
      settle: false, // the indicator spins forever
    );
    if (isApple(platform)) {
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    } else {
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
    }
    expect(find.bySemanticsLabel('جاري التحميل'), findsWidgets);
    handle.dispose();
  }, variant: allPlatforms);
}
