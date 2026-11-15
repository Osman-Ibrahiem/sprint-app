import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/widgets/status_badge/sprint_status.dart';
import 'package:sprint/core/widgets/status_badge/status_badge.dart';

import '../../helpers/widget_harness.dart';

void main() {
  final colors = SprintColors.light;

  Future<void> pump(
    WidgetTester tester,
    SprintStatus status, {
    Locale locale = const Locale('ar'),
    bool dark = false,
    double textScale = 1,
  }) =>
      pumpWidgetUnderAndSettle(
        tester,
        StatusBadge(status: status),
        locale: locale,
        dark: dark,
        textScale: textScale,
      );

  BoxDecoration decoration(WidgetTester tester) {
    final container = tester.widget<Container>(
      find.byKey(StatusBadge.containerKey),
    );
    return container.decoration! as BoxDecoration;
  }

  final table = <SprintStatus, (String ar, String en, Color fg, Color bg)>{
    SprintStatus.confirmed: (
      'مؤكد',
      'Confirmed',
      colors.success,
      colors.successSoft,
    ),
    SprintStatus.pendingPayment: (
      'في انتظار الدفع',
      'Awaiting payment',
      colors.warning,
      colors.warningSoft,
    ),
    SprintStatus.cancelled: (
      'اتلغى',
      'Cancelled',
      colors.danger,
      colors.dangerSoft,
    ),
    SprintStatus.attended: (
      'حضر',
      'Attended',
      colors.onPrimarySoft,
      colors.primarySoft,
    ),
    SprintStatus.noShow: (
      'غاب',
      'No-show',
      colors.inkMuted,
      colors.surfaceSunken,
    ),
    SprintStatus.expired: (
      'انتهت المهلة',
      'Expired',
      colors.inkMuted,
      colors.surfaceSunken,
    ),
    SprintStatus.underReview: (
      'قيد المراجعة',
      'Under review',
      colors.warning,
      colors.warningSoft,
    ),
    SprintStatus.verified: (
      'موثّق',
      'Verified',
      colors.success,
      colors.successSoft,
    ),
    SprintStatus.rejected: (
      'مرفوض',
      'Rejected',
      colors.danger,
      colors.dangerSoft,
    ),
    SprintStatus.open: (
      'مفتوح',
      'Open',
      colors.warning,
      colors.warningSoft,
    ),
    SprintStatus.inProgress: (
      'جاري',
      'In progress',
      colors.onPrimarySoft,
      colors.primarySoft,
    ),
    SprintStatus.resolved: (
      'اتحل',
      'Resolved',
      colors.success,
      colors.successSoft,
    ),
  };

  testWidgets('all twelve statuses show their word, icon and colours',
      (tester) async {
    expect(table.keys.toSet(), SprintStatus.values.toSet());

    for (final MapEntry(key: status, value: (ar, en, fg, bg))
        in table.entries) {
      await pump(tester, status);
      expect(find.text(ar), findsOneWidget, reason: status.name);
      expect(find.byIcon(status.icon), findsOneWidget, reason: status.name);

      final box = decoration(tester);
      expect(box.color, bg, reason: '${status.name} background');
      final word = tester.widget<Text>(find.byKey(StatusBadge.wordKey));
      expect(word.style!.color, fg, reason: '${status.name} foreground');
      final icon = tester.widget<Icon>(find.byIcon(status.icon));
      expect(icon.color, fg, reason: '${status.name} icon');

      await pump(tester, status, locale: const Locale('en'));
      expect(find.text(en), findsOneWidget, reason: '${status.name} English');
    }
  });

  testWidgets('dark mode uses the dark colour pair', (tester) async {
    await pump(tester, SprintStatus.confirmed, dark: true);
    expect(decoration(tester).color, SprintColors.dark.successSoft);
    final word = tester.widget<Text>(find.byKey(StatusBadge.wordKey));
    expect(word.style!.color, SprintColors.dark.success);
  });

  testWidgets('no-show and expired are neutral', (tester) async {
    for (final status in [SprintStatus.noShow, SprintStatus.expired]) {
      await pump(tester, status);
      final box = decoration(tester);
      expect(box.color, colors.surfaceSunken, reason: status.name);
      final word = tester.widget<Text>(find.byKey(StatusBadge.wordKey));
      expect(word.style!.color, colors.inkMuted, reason: status.name);
    }
  });

  testWidgets('success and danger badges differ without colour', (tester) async {
    await pump(tester, SprintStatus.confirmed);
    expect(find.byIcon(SprintStatus.confirmed.icon), findsOneWidget);
    expect(find.byIcon(SprintStatus.cancelled.icon), findsNothing);

    await pump(tester, SprintStatus.cancelled);
    expect(find.byIcon(SprintStatus.cancelled.icon), findsOneWidget);
    expect(find.byIcon(SprintStatus.confirmed.icon), findsNothing);
    expect(
      SprintStatus.confirmed.icon,
      isNot(SprintStatus.cancelled.icon),
    );
  });

  testWidgets('the pill is 28 high with a full radius', (tester) async {
    await pump(tester, SprintStatus.confirmed);
    expect(
      tester.getSize(find.byKey(StatusBadge.containerKey)).height,
      SprintExtras.statusBadgeHeight,
    );
    expect(decoration(tester).borderRadius, SprintRadius.fullBorder);
  });

  testWidgets('not pressable', (tester) async {
    await pump(tester, SprintStatus.confirmed);
    expect(find.byType(GestureDetector), findsNothing);
    expect(find.byType(InkWell), findsNothing);

    final handle = tester.ensureSemantics();
    final semantics = tester.getSemantics(find.byType(StatusBadge));
    expect(semantics.flagsCollection.isLiveRegion, isTrue);
    expect(semantics.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
    expect(semantics.getSemanticsData().hasFlag(SemanticsFlag.isButton), isFalse);
    handle.dispose();
  });

  testWidgets('spoken as "الحالة: مؤكد"', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, SprintStatus.confirmed);
    expect(
      tester.getSemantics(find.byType(StatusBadge)).label,
      'الحالة: مؤكد',
    );
    handle.dispose();

    await pump(tester, SprintStatus.confirmed, locale: const Locale('en'));
    final handleEn = tester.ensureSemantics();
    expect(
      tester.getSemantics(find.byType(StatusBadge)).label,
      'Status: Confirmed',
    );
    handleEn.dispose();
  });

  testWidgets('a status change swaps icon, word and colour together and is '
      'announced', (tester) async {
    await pump(tester, SprintStatus.confirmed);
    expect(find.text('مؤكد'), findsOneWidget);
    expect(decoration(tester).color, colors.successSoft);

    await pump(tester, SprintStatus.rejected);
    expect(find.text('مؤكد'), findsNothing);
    expect(find.text('مرفوض'), findsOneWidget);
    expect(find.byIcon(SprintStatus.rejected.icon), findsOneWidget);
    expect(decoration(tester).color, colors.dangerSoft);

    final handle = tester.ensureSemantics();
    final semantics = tester.getSemantics(find.byType(StatusBadge));
    expect(semantics.flagsCollection.isLiveRegion, isTrue);
    expect(semantics.label, 'الحالة: مرفوض');
    handle.dispose();
  });

  testWidgets('200% text does not overflow', (tester) async {
    await pump(tester, SprintStatus.pendingPayment, textScale: 2);
    expect(tester.takeException(), isNull);
  });
}
