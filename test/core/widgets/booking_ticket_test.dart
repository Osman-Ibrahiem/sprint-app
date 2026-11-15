import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/widgets/booking_ticket/booking_ticket.dart';
import 'package:sprint/core/widgets/status_badge/sprint_status.dart';

import '../../helpers/widget_harness.dart';

BookingTicket ticket({
  BookingTicketState state = BookingTicketState.upcoming,
  SprintStatus status = SprintStatus.confirmed,
  String? token = 'qr.abc123.x1',
  DateTime? cancelUntil,
  String? trainer,
  VoidCallback? onCopied,
}) =>
    BookingTicket(
      state: state,
      status: status,
      facilityName: 'حمام السباحة',
      unitName: 'حارة 3',
      trainerName: trainer,
      start: DateTime(2026, 11, 10, 17),
      end: DateTime(2026, 11, 10, 18),
      qrToken: token,
      code: 'SPR-4821',
      paid: '120 ج.م',
      cancelUntil: cancelUntil,
      onCodeCopied: onCopied,
    );

BoxDecoration? _bg(WidgetTester tester, Key key) {
  final w = tester.widget<Container>(find.byKey(key));
  return w.decoration as BoxDecoration?;
}

void main() {
  final light = SprintColors.light;

  testWidgets('upcoming band is volt with on-volt text', (tester) async {
    await pumpWidgetUnderAndSettle(tester, ticket());
    final band = tester.widget<Container>(find.byKey(BookingTicket.bandKey));
    expect(band.color, light.volt);
    final text = tester.widget<Text>(
      find.descendant(
        of: find.byKey(BookingTicket.bandKey),
        matching: find.byType(Text),
      ),
    );
    expect(text.style!.color, light.onVolt);
    expect(text.data, contains('·'));
  });

  testWidgets('past band is surface-sunken with ink-muted', (tester) async {
    await pumpWidgetUnderAndSettle(
      tester,
      ticket(state: BookingTicketState.past, status: SprintStatus.attended),
    );
    final band = tester.widget<Container>(find.byKey(BookingTicket.bandKey));
    expect(band.color, light.surfaceSunken);
  });

  testWidgets('QR shown for upcoming, hidden for past and cancelled',
      (tester) async {
    await pumpWidgetUnderAndSettle(tester, ticket());
    expect(find.byKey(BookingTicket.qrKey), findsOneWidget);
    await pumpWidgetUnderAndSettle(
      tester,
      ticket(state: BookingTicketState.past, status: SprintStatus.attended),
    );
    expect(find.byKey(BookingTicket.qrKey), findsNothing);
    await pumpWidgetUnderAndSettle(
      tester,
      ticket(status: SprintStatus.cancelled),
    );
    expect(find.byKey(BookingTicket.qrKey), findsNothing);
  });

  testWidgets('empty and over-long tokens show QR غير متاح', (tester) async {
    for (final token in ['', null, 'x' * 5000]) {
      await pumpWidgetUnderAndSettle(tester, ticket(token: token));
      expect(find.byKey(BookingTicket.qrUnavailableKey), findsOneWidget);
      expect(find.text('QR غير متاح'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('code is LTR and copying announces اتنسخ', (tester) async {
    final log = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        log.add(call);
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    var copied = 0;
    await pumpWidgetUnderAndSettle(tester, ticket(onCopied: () => copied++));
    final direction = Directionality.of(
      tester.element(find.byKey(BookingTicket.codeKey)),
    );
    expect(direction, TextDirection.ltr);
    await tester.tap(find.byKey(BookingTicket.codeKey));
    await tester.pump();
    expect(log.any((c) => c.method == 'Clipboard.setData'), isTrue);
    expect(copied, 1);
    expect(find.text('اتنسخ'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('cancellation row, with and without a cut-off', (tester) async {
    await pumpWidgetUnderAndSettle(tester, ticket());
    expect(find.text('الإلغاء مش متاح'), findsOneWidget);
    await pumpWidgetUnderAndSettle(
      tester,
      ticket(cancelUntil: DateTime(2026, 11, 9, 17)),
    );
    expect(find.textContaining('إلغاء مجاني لحد'), findsOneWidget);
  });

  testWidgets('340 wide on a wide window, with a divider and a paid row',
      (tester) async {
    await pumpWidgetUnderAndSettle(
      tester,
      ticket(),
      size: const Size(900, 1000),
    );
    expect(
      tester.getSize(find.byKey(BookingTicket.cardKey)).width,
      SprintExtras.ticketWidth,
    );
    expect(find.byKey(BookingTicket.dividerKey), findsOneWidget);
    expect(find.text('120 ج.م'), findsOneWidget);
  });

  testWidgets('spoken label has facility, status and the code by digit',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pumpWidgetUnderAndSettle(tester, ticket());
    final label = tester
        .getSemantics(find.bySemanticsLabel(RegExp('تذكرة')).first)
        .label;
    expect(label, contains('حمام السباحة'));
    expect(label, contains('S P R - 4 8 2 1'));
    handle.dispose();
  });

  testWidgets('loading form is silent to readers', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpWidgetUnder(tester, const BookingTicket.loading());
    expect(find.byKey(BookingTicket.loadingKey), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('.+')), findsNothing);
    handle.dispose();
  });
}
