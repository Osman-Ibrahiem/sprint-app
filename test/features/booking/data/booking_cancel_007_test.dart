import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/booking/domain/cancel_preview.dart';
import 'package:sprint/features/payments/data/fake_gateway_controller.dart';
import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';

import '../../../helpers/data_env.dart';

/// BR-30 – BR-32, BR-47, BR-48 through the repositories: one refund, one
/// notification, an idempotent second cancel, and a Hold released at once.
void main() {
  late DataEnv env;
  late FakeGatewayController gateway;

  setUp(() {
    env = DataEnv();
    gateway = env.layer.paymentProvider.gateway;
  });

  T ok<T>(Result<T> r) => (r as Ok<T>).value;
  Failure fail<T>(Result<T> r) => (r as Err<T>).failure;

  BookingRequest req(String user, String unit, DateTime start) => BookingRequest(
        userId: user,
        unitId: unit,
        start: start,
        end: start.add(const Duration(hours: 1)),
      );

  Future<Booking> create(String user, String unit, DateTime start) async =>
      ok(await env.layer.bookings.create(req(user, unit, start)));

  Future<Booking> pay(Booking b, {String last4 = '4242'}) async {
    final s = ok(await env.layer.bookings.startPayment(b.id, b.userId));
    gateway.confirm(s.id, cardLast4: last4);
    await Future<void>.delayed(const Duration(milliseconds: 60));
    return ok(await env.layer.bookings.get(b.id));
  }

  Future<List<Payment>> payments(Booking b) =>
      env.layer.payments.payments(b.id);

  test('an owner cancel before the cutoff refunds once and writes a read '
      '"cancelled by me" record', () async {
    final b = await pay(await create(
      Ids.bookerInternal,
      Ids.futsal2,
      env.at(2, 18),
    ));

    final r = ok(await env.layer.bookings.cancel(b.id, Ids.bookerInternal));
    expect(r.status, BookingStatus.cancelled);
    expect(r.cancelledBy, CancelledBy.owner);
    expect(r.cancelledAt, env.now);

    final payment = (await payments(b)).single;
    expect((await env.layer.payments.refunds(payment.id)).single.amount, 140);

    final note = (await env.layer.notifications.list(Ids.bookerInternal))
        .singleWhere((n) => n.type == 'booking.cancelled_by_owner');
    expect(note.readAt, note.sentAt);
    expect(note.payload['bookingId'], b.id);
    expect(note.payload['code'], b.code);
    expect(note.payload['amount'], '140');
  });

  test('a second cancel returns the same booking and writes nothing more',
      () async {
    final b = await pay(await create(
      Ids.bookerInternal,
      Ids.futsal2,
      env.at(2, 18),
    ));
    ok(await env.layer.bookings.cancel(b.id, Ids.bookerInternal));

    final before = (await env.layer.notifications.list(Ids.bookerInternal))
        .where((n) => n.type == 'booking.cancelled_by_owner')
        .length;
    final refundsBefore =
        await env.layer.payments.refunds((await payments(b)).single.id);

    final again = ok(await env.layer.bookings.cancel(b.id, Ids.bookerInternal));
    expect(again.status, BookingStatus.cancelled);
    expect(
      (await env.layer.notifications.list(Ids.bookerInternal))
          .where((n) => n.type == 'booking.cancelled_by_owner')
          .length,
      before,
    );
    expect(
      await env.layer.payments.refunds((await payments(b)).single.id),
      hasLength(refundsBefore.length),
    );
  });

  test('after the cutoff an owner cancel is closed', () async {
    final slot = env.at(2, 18);
    final b = await pay(await create(Ids.bookerInternal, Ids.futsal2, slot));
    env.setNow(slot.subtract(const Duration(hours: 1, minutes: 59)));
    expect(
      fail(await env.layer.bookings.cancel(b.id, Ids.bookerInternal)),
      isA<CancellationClosed>(),
    );
  });

  test('a free booking refunds nothing but still notifies its owner', () async {
    final b = await create(Ids.bookerExternal, Ids.hall2, env.at(2, 10));
    expect(b.priceAtBooking, 0);

    final r = ok(await env.layer.bookings.cancel(b.id, Ids.bookerExternal));
    expect(r.status, BookingStatus.cancelled);
    expect(await payments(b), isEmpty);

    final note = (await env.layer.notifications.list(Ids.bookerExternal))
        .singleWhere((n) => n.type == 'booking.cancelled_by_owner');
    expect(note.payload['amount'], '0');
  });

  test('an admin cancel is a full refund whatever the setting (BR-32)',
      () async {
    await env.layer.settings.set(
      SettingKeys.refundPercent,
      0,
      const SettingScope.unit(Ids.futsal2),
      actorId: Ids.superAdmin,
    );
    final b = await pay(await create(
      Ids.bookerInternal,
      Ids.futsal2,
      env.at(2, 18),
    ));

    final r = ok(await env.layer.bookings
        .cancel(b.id, Ids.superAdmin, reason: 'إغلاق طارئ'));
    expect(r.cancelledBy, CancelledBy.admin);
    expect(r.cancelledAt, env.now);
    expect(
      (await env.layer.payments.refunds((await payments(b)).single.id))
          .single
          .amount,
      140,
    );
    expect(
      (await env.layer.notifications.list(Ids.bookerInternal))
          .any((n) => n.type == 'booking.cancelled_by_admin'),
      isTrue,
    );
  });

  test('the owner can cancel a live Hold with no payment and the place is free '
      'at once (BR-48)', () async {
    final slot = env.at(2, 18);
    final b = await create(Ids.bookerInternal, Ids.futsal2, slot);
    expect(b.status, BookingStatus.pendingPayment);

    final r = ok(await env.layer.bookings.cancel(b.id, Ids.bookerInternal));
    expect(r.status, BookingStatus.cancelled);
    expect(r.cancelledBy, CancelledBy.owner);
    expect(await payments(b), isEmpty);

    final other = await create(Ids.bookerExternal, Ids.futsal2, slot);
    expect(other.status, BookingStatus.pendingPayment);
  });

  test('a payment being confirmed closes the holder cancel (BR-47)', () async {
    final b = await create(Ids.bookerInternal, Ids.futsal2, env.at(2, 18));
    ok(await env.layer.bookings.startPayment(b.id, b.userId));

    expect(
      fail(await env.layer.bookings.cancel(b.id, Ids.bookerInternal)),
      isA<InvalidTransition>(),
    );
    expect(ok(await env.layer.bookings.get(b.id)).status,
        BookingStatus.pendingPayment);
  });

  test('a Hold that already ended cannot be cancelled and is expired',
      () async {
    final b = await create(Ids.bookerInternal, Ids.futsal2, env.at(2, 18));
    env.advance(const Duration(minutes: 11));

    expect(
      fail(await env.layer.bookings.cancel(b.id, Ids.bookerInternal)),
      isA<InvalidTransition>(),
    );
    expect(ok(await env.layer.bookings.get(b.id)).status,
        BookingStatus.expired);
  });

  test('previewCancel never mutates', () async {
    final b = await pay(await create(
      Ids.bookerInternal,
      Ids.futsal2,
      env.at(2, 18),
    ));
    final notesBefore =
        (await env.layer.notifications.list(Ids.bookerInternal)).length;

    final preview = await env.layer.bookings.previewCancel(
      b.id,
      Ids.bookerInternal,
    );
    expect(preview.kind, CancelKind.full);
    expect(preview.paidAmount, 140);
    expect(preview.refundAmount, 140);

    final after = ok(await env.layer.bookings.get(b.id));
    expect(after, b);
    expect(
      (await env.layer.notifications.list(Ids.bookerInternal)).length,
      notesBefore,
    );
    expect(await env.layer.payments.refunds((await payments(b)).single.id),
        isEmpty);
  });
}
