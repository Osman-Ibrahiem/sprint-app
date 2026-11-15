import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/widgets/stat_tile/stat_tile.dart';

import '../../helpers/widget_harness.dart';

StatTile tile({StatDelta? delta, VoidCallback? onTap, String? unit}) =>
    StatTile(
      label: 'الإيراد',
      period: 'الأسبوع ده',
      value: '1,250,000',
      unit: unit,
      delta: delta,
      onTap: onTap,
    );

StatDelta delta(StatTrend t, {bool better = true}) => StatDelta(
      trend: t,
      text: '12%',
      comparison: 'عن الأسبوع اللي فات',
      higherIsBetter: better,
    );

Color deltaColor(WidgetTester tester) {
  final text = tester.widget<Text>(
    find.descendant(
      of: find.byKey(StatTile.deltaKey),
      matching: find.byType(Text),
    ),
  );
  return text.style!.color!;
}

void main() {
  final c = SprintColors.light;

  testWidgets('label, period, value and unit', (tester) async {
    await pumpWidgetUnderAndSettle(tester, tile(unit: 'ج.م'));
    expect(find.text('الإيراد'), findsOneWidget);
    expect(find.text('الأسبوع ده'), findsOneWidget);
    expect(find.textContaining('1,250,000'), findsOneWidget);
    expect(find.textContaining('ج.م'), findsOneWidget);
  });

  testWidgets('delta sentence names direction and comparison', (tester) async {
    await pumpWidgetUnderAndSettle(tester, tile(delta: delta(StatTrend.up)));
    expect(find.text('زيادة 12% عن الأسبوع اللي فات'), findsOneWidget);
    expect(deltaColor(tester), c.success);
  });

  testWidgets('good or bad comes from higherIsBetter', (tester) async {
    await pumpWidgetUnderAndSettle(
      tester,
      tile(delta: delta(StatTrend.up, better: false)),
    );
    expect(deltaColor(tester), c.danger);
    await pumpWidgetUnderAndSettle(
      tester,
      tile(delta: delta(StatTrend.down, better: false)),
    );
    expect(deltaColor(tester), c.success);
    await pumpWidgetUnderAndSettle(tester, tile(delta: delta(StatTrend.down)));
    expect(find.textContaining('نقص 12%'), findsOneWidget);
    expect(deltaColor(tester), c.danger);
  });

  testWidgets('flat is neutral; no delta says مفيش مقارنة', (tester) async {
    await pumpWidgetUnderAndSettle(tester, tile(delta: delta(StatTrend.flat)));
    expect(find.text('مفيش تغيير'), findsOneWidget);
    expect(deltaColor(tester), c.inkMuted);
    await pumpWidgetUnderAndSettle(tester, tile());
    expect(find.text('مفيش مقارنة'), findsOneWidget);
  });

  testWidgets('pressable only with onTap', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpWidgetUnderAndSettle(tester, tile());
    expect(
      tester.getSemantics(find.byType(StatTile)).flagsCollection.isButton,
      isFalse,
    );
    var taps = 0;
    await pumpWidgetUnderAndSettle(tester, tile(onTap: () => taps++));
    await tester.tap(find.byType(StatTile));
    expect(taps, 1);
    handle.dispose();
  });

  testWidgets('English renders the same tile', (tester) async {
    await pumpWidgetUnderAndSettle(
      tester,
      tile(delta: delta(StatTrend.up)),
      locale: const Locale('en'),
    );
    expect(find.textContaining('Up 12%'), findsOneWidget);
  });

  testWidgets('loading form is silent and keeps the keyed shape',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pumpWidgetUnder(tester, const StatTile.loading());
    expect(find.byKey(StatTile.loadingKey), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('.+')), findsNothing);
    handle.dispose();
  });
}
