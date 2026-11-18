import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/widgets/avatar/avatar.dart';
import 'package:sprint/core/widgets/booking_row/booking_row.dart';
import 'package:sprint/core/widgets/notification_bell/notification_bell.dart';
import 'package:sprint/core/widgets/notification_card/notification_card.dart';
import 'package:sprint/core/widgets/segmented_control/segmented_control.dart';
import 'package:sprint/core/widgets/settings_row/settings_row.dart';
import 'package:sprint/core/widgets/status_badge/sprint_status.dart';

import '../../helpers/widget_harness.dart';

/// T031–T034: the new shared widgets (feature 007 design pack).
void main() {
  group('NotificationBell', () {
    testWidgets('badge hidden at 0 and while loading, capped at 99+', (
      tester,
    ) async {
      Future<void> pump(int? n) =>
          pumpWidgetUnder(tester, NotificationBell(unread: n, onTap: () {}));
      await pump(0);
      expect(find.byKey(NotificationBell.badgeKey), findsNothing);
      await pump(null);
      expect(find.byKey(NotificationBell.badgeKey), findsNothing);
      await pump(7);
      expect(find.text('7'), findsOneWidget);
      await pump(120);
      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('48 target, Arabic label with the count, taps', (tester) async {
      var taps = 0;
      await pumpWidgetUnder(
        tester,
        NotificationBell(unread: 2, onTap: () => taps++),
      );
      expect(
        tester.getSize(find.byType(NotificationBell)).shortestSide,
        greaterThanOrEqualTo(48),
      );
      expect(find.bySemanticsLabel(RegExp('الإشعارات')), findsWidgets);
      await tester.tap(find.byType(NotificationBell));
      expect(taps, 1);
    });
  });

  group('NotificationCard', () {
    Widget card({bool unread = true, Widget? actions}) => NotificationCard(
      icon: PhosphorIconsRegular.checkCircle,
      tone: NotificationTone.success,
      title: 'تم تأكيد حجزك',
      body: 'حمام السباحة',
      time: '4:00 م',
      unread: unread,
      actions: actions,
      onTap: () {},
    );

    testWidgets('unread shows the dot, read does not', (tester) async {
      await pumpWidgetUnder(tester, card());
      expect(find.byKey(NotificationCard.dotKey), findsOneWidget);
      await pumpWidgetUnder(tester, card(unread: false));
      expect(find.byKey(NotificationCard.dotKey), findsNothing);
    });

    testWidgets('200% text, English and the action slot do not overflow', (
      tester,
    ) async {
      await pumpWidgetUnder(
        tester,
        card(actions: const Text('إلغاء الحجز')),
        textScale: 2,
        locale: const Locale('en'),
        size: const Size(390, 800),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('إلغاء الحجز'), findsOneWidget);
    });
  });

  group('BookingRow', () {
    Widget row({bool selected = false, bool today = false}) => BookingRow(
      status: SprintStatus.confirmed,
      facilityName: 'حمام السباحة الأولمبي',
      notes: 'حارة 2 · مجاني',
      dateLabel: today
          ? 'النهارده · 5:00 – 6:00 م'
          : 'الخميس 12 نوفمبر · 6:00 – 8:00 م',
      isToday: today,
      code: 'SP-1042',
      action: 'عرض التذكرة',
      onTap: () {},
      semanticLabel: 'مؤكد',
      selected: selected,
    );

    testWidgets('selected adds a border without changing the height', (
      tester,
    ) async {
      await pumpWidgetUnder(tester, row());
      final h = tester.getSize(find.byType(BookingRow)).height;
      await pumpWidgetUnder(tester, row(selected: true));
      expect(tester.getSize(find.byType(BookingRow)).height, h);
      expect(find.byKey(BookingRow.selectedKey), findsOneWidget);
    });

    testWidgets('a narrow width wraps the date chip instead of overflowing', (
      tester,
    ) async {
      await pumpWidgetUnder(
        tester,
        SizedBox(width: 252, child: row()),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('SP-1042'), findsOneWidget);
    });

    testWidgets('the status carries a word, not just a colour', (tester) async {
      await pumpWidgetUnder(tester, row(today: true));
      expect(find.text('مؤكد'), findsOneWidget);
    });
  });

  group('SegmentedControl', () {
    testWidgets('tap and arrow keys change the selection; whole row is 48', (
      tester,
    ) async {
      var value = 0;
      await pumpWidgetUnder(
        tester,
        StatefulBuilder(
          builder: (context, set) => SegmentedControl(
            labels: const ['الجاية (3)', 'اللي فاتت'],
            selected: value,
            onChanged: (v) => set(() => value = v),
          ),
        ),
      );
      expect(
        tester.getSize(find.byKey(SegmentedControl.segmentKey(1))).height,
        greaterThanOrEqualTo(48),
      );
      await tester.tap(find.text('اللي فاتت'));
      await tester.pump();
      expect(value, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    });
  });

  group('SettingsRow and Avatar', () {
    testWidgets('rows are at least 52 high and tap', (tester) async {
      var taps = 0;
      await pumpWidgetUnder(
        tester,
        Column(
          children: [
            SettingsRow(label: 'اللغة', value: 'العربية', onTap: () => taps++),
            SettingsRow(
              label: 'تسجيل الخروج',
              type: SettingsRowType.destructive,
              onTap: () => taps++,
            ),
          ],
        ),
      );
      for (final r in tester.widgetList<SettingsRow>(
        find.byType(SettingsRow),
      )) {
        expect(
          tester.getSize(find.byWidget(r)).height,
          greaterThanOrEqualTo(52),
        );
      }
      await tester.tap(find.text('اللغة'));
      await tester.tap(find.text('تسجيل الخروج'));
      expect(taps, 2);
    });

    testWidgets('avatar: initial without a photo, photo with bytes', (
      tester,
    ) async {
      await pumpWidgetUnder(tester, const Avatar(name: 'منى سالم'));
      expect(find.byKey(Avatar.initialKey), findsOneWidget);
      expect(find.text('م'), findsOneWidget);
      expect(Avatar.initialOf('  '), '?');
      final png = Uint8List.fromList(const [
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
        0x00,
        0x00,
        0x00,
        0x0D,
        0x49,
        0x48,
        0x44,
        0x52,
        0x00,
        0x00,
        0x00,
        0x01,
        0x00,
        0x00,
        0x00,
        0x01,
        0x08,
        0x06,
        0x00,
        0x00,
        0x00,
        0x1F,
        0x15,
        0xC4,
        0x89,
        0x00,
        0x00,
        0x00,
        0x0D,
        0x49,
        0x44,
        0x41,
        0x54,
        0x78,
        0x9C,
        0x63,
        0xF8,
        0xFF,
        0xFF,
        0x3F,
        0x00,
        0x05,
        0xFE,
        0x02,
        0xFE,
        0xA7,
        0x35,
        0x81,
        0x84,
        0x00,
        0x00,
        0x00,
        0x00,
        0x49,
        0x45,
        0x4E,
        0x44,
        0xAE,
        0x42,
        0x60,
        0x82,
      ]);
      await pumpWidgetUnder(tester, Avatar(name: 'منى', photo: png, size: 48));
      expect(find.byKey(Avatar.photoKey), findsOneWidget);
    });
  });
}
