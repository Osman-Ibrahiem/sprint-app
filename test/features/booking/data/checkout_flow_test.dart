import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/payments/data/fake_gateway_controller.dart';
import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/payments/domain/payment_provider.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';

import '../../../helpers/data_env.dart';

/// BR-12, BR-28, BR-46, BR-47 on the in-memory repositories. The clock the
/// rules read is the environment's (`env.advance`); the fake provider runs
/// on real, very short timers.
void main() {
  late DataEnv env;
  late InMemoryDataLayer layer;
  late FakeGatewayController gateway;

  setUp(() {
    env = DataEnv();
    layer = env.layer;
    gateway = layer.paymentProvider.gateway;
  });

  Future<void> settle([int ms = 60]) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  T ok<T>(Result<T> r) => (r as Ok<T>).value;
  Failure fail<T>(Result<T> r) => (r as Err<T>).failure;

  BookingRequest req(String user, {int slot = 18}) => BookingRequest(
        userId: user,
        unitId: Ids.futsal2,
        start: env.at(2, slot),
        end: env.at(2, slot + 1),
      );

  Future<Booking> create({String user = Ids.bookerInternal, int slot = 18}) async =>
      ok(await layer.bookings.create(req(user, slot: slot)));

  Future<Booking> get(String id) async => ok(await layer.bookings.get(id));

  /// Starts a payment, lets the page confirm, and settles.
  Future<PaymentSession> pay(Booking b, {String? user, String last4 = '4242'}) async {
    final s = ok(await layer.bookings.startPayment(b.id, user ?? b.userId));
    gateway.confirm(s.id, cardLast4: last4);
    return s;
  }

  Future<Payment?> latest(Booking b) => layer.payments.latestPayment(b.id);

  Future<List<Notification0>> notes(String user) async => [
        for (final n in await layer.notifications.list(user))
          Notification0(n.type, n.payload),
      ];

  test('(a) a paid create sets status and hold fields and no payment', () async {
    final b = await create();
    expect(b.status, BookingStatus.pendingPayment);
    expect(b.holdStartedAt, env.now);
    expect(b.holdExpiresAt, env.now.add(const Duration(minutes: 10)));
    expect(b.holdMaxExpiresAt, env.now.add(const Duration(minutes: 20)));
    expect(await latest(b), isNull);
  });

  test('(b) startPayment writes a pending payment; a second call returns the '
      'same session', () async {
    final b = await create();
    final s1 = ok(await layer.bookings.startPayment(b.id, b.userId));
    final p = (await latest(b))!;
    expect(p.status, PaymentStatus.pending);
    expect(p.startedAt, env.now);
    expect(p.owningUnitId, Ids.ouCentral); // BR-33
    expect(p.providerRef, s1.id);
    final s2 = ok(await layer.bookings.startPayment(b.id, b.userId));
    expect(s2.id, s1.id);
    expect(s2.checkoutLocation, s1.checkoutLocation);
    expect(await layer.payments.payments(b.id), hasLength(1));
  });

  test('(c) succeeded confirms, records the payment and one notification',
      () async {
    final b = await create();
    await pay(b);
    await settle();
    final c = await get(b.id);
    expect(c.status, BookingStatus.confirmed);
    expect(c.holdExpiresAt, isNull);
    final p = (await latest(b))!;
    expect(p.status, PaymentStatus.succeeded);
    expect(p.paidAt, isNotNull);
    expect(p.cardLast4, '4242');
    expect(p.receiptNumber, matches(RegExp(r'^RC-\d{6}-\d{4}$')));
    final confirmed =
        (await notes(b.userId)).where(
            (n) => n.type == 'booking.confirmed' && n.payload['code'] == b.code);
    expect(confirmed, hasLength(1));
  });

  test('(d) failed keeps the booking pending with the same Hold and no '
      'notification', () async {
    gateway.outcome = const FakeOutcome.fail();
    final b = await create();
    final before = (await notes(b.userId)).length;
    await pay(b);
    await settle();
    final c = await get(b.id);
    expect(c.status, BookingStatus.pendingPayment);
    expect(c.holdExpiresAt, b.holdExpiresAt);
    expect((await latest(b))!.status, PaymentStatus.failed);
    expect((await notes(b.userId)).length, before);
  });

  test('(e) cancelled keeps the booking pending with the same Hold', () async {
    final b = await create();
    final s = ok(await layer.bookings.startPayment(b.id, b.userId));
    gateway.cancel(s.id);
    await settle();
    final c = await get(b.id);
    expect(c.status, BookingStatus.pendingPayment);
    expect(c.holdExpiresAt, b.holdExpiresAt);
    expect((await latest(b))!.status, PaymentStatus.cancelled);
  });

  test('(f) retry after a failure creates a second payment', () async {
    gateway.outcome = const FakeOutcome.fail();
    final b = await create();
    await pay(b);
    await settle();
    gateway.outcome = const FakeOutcome.succeed();
    await pay(b);
    await settle();
    final all = await layer.payments.payments(b.id);
    expect(all, hasLength(2));
    expect(all.map((p) => p.status).toSet(),
        {PaymentStatus.failed, PaymentStatus.succeeded});
    expect((await get(b.id)).status, BookingStatus.confirmed);
  });

  test('(g) the Hold reached with no payment expires the booking and frees '
      'the place', () async {
    final b = await create();
    env.advance(const Duration(minutes: 10));
    expect(await layer.bookings.expireHolds(), 1 + _seedPendingCount);
    expect((await get(b.id)).status, BookingStatus.expired);
    expect(await layer.bookings.create(req(Ids.bookerExternal)), isA<Ok<Booking>>());
  });

  test('(h) the Hold reached with a pending payment extends to the maximum '
      'and keeps the place', () async {
    final b = await create();
    ok(await layer.bookings.startPayment(b.id, b.userId));
    env.advance(const Duration(minutes: 10));
    await layer.bookings.expireHolds();
    final c = await get(b.id);
    expect(c.status, BookingStatus.pendingPayment);
    expect(c.holdExpiresAt, b.holdMaxExpiresAt);
    // The place is still held: another account is refused.
    expect(fail(await layer.bookings.create(req(Ids.bookerExternal))),
        isA<SlotTaken>());
  });

  test('(i) the maximum reached while pending expires; a late success is '
      'refunded in full and the booking stays expired', () async {
    final b = await create();
    final s = ok(await layer.bookings.startPayment(b.id, b.userId));
    env.advance(const Duration(minutes: 10));
    await layer.bookings.expireHolds(); // extended
    env.advance(const Duration(minutes: 10));
    await layer.bookings.expireHolds(); // maximum reached
    expect((await get(b.id)).status, BookingStatus.expired);
    expect((await latest(b))!.status, PaymentStatus.pending);

    // Another booking takes the place, then the late success arrives.
    ok(await layer.bookings.create(req(Ids.bookerExternal)));
    gateway.confirm(s.id, cardLast4: '4242');
    await settle();
    final p = (await latest(b))!;
    expect(p.status, PaymentStatus.succeeded);
    expect((await get(b.id)).status, BookingStatus.expired);
    final refunds = await layer.payments.refunds(p.id);
    expect(refunds, hasLength(1));
    expect(refunds.single.amount, p.amount);
    expect(refunds.single.reason, 'late_confirmation');
    final auto = (await notes(b.userId))
        .where((n) => n.type == 'payment.refunded_auto');
    expect(auto, hasLength(1));
    expect(auto.single.payload['amount'], '${p.amount}');
  });

  test('(i) a late success is refunded when no one else took the place',
      () async {
    final b = await create();
    final s = ok(await layer.bookings.startPayment(b.id, b.userId));
    env.advance(const Duration(minutes: 25));
    await layer.bookings.expireHolds();
    gateway.confirm(s.id, cardLast4: '4242');
    await settle();
    expect((await get(b.id)).status, BookingStatus.expired);
    expect(await layer.payments.refunds((await latest(b))!.id), hasLength(1));
  });

  test('(j) leaveCheckout expires at once and a late success refunds',
      () async {
    final b = await create();
    final s = ok(await layer.bookings.startPayment(b.id, b.userId));
    final left = ok(await layer.bookings.leaveCheckout(b.id, b.userId));
    expect(left.status, BookingStatus.expired);
    gateway.confirm(s.id, cardLast4: '4242');
    await settle();
    expect((await get(b.id)).status, BookingStatus.expired);
    expect(await layer.payments.refunds((await latest(b))!.id), hasLength(1));
  });

  test('(k) another account is refused the last place while a Hold or an '
      'extended Hold is live', () async {
    final b = await create();
    expect(fail(await layer.bookings.create(req(Ids.bookerExternal))),
        isA<SlotTaken>());
    ok(await layer.bookings.startPayment(b.id, b.userId));
    env.advance(const Duration(minutes: 10)); // no tick yet
    expect(fail(await layer.bookings.create(req(Ids.bookerExternal))),
        isA<SlotTaken>());
  });

  test('(l) startPayment by another user is refused; on an expired Hold it '
      'says HoldExpired', () async {
    final b = await create();
    expect(fail(await layer.bookings.startPayment(b.id, Ids.bookerExternal)),
        isA<NotPermitted>());
    env.advance(const Duration(minutes: 11));
    expect(fail(await layer.bookings.startPayment(b.id, b.userId)),
        isA<HoldExpired>());
    expect(await latest(b), isNull);
  });

  test('(m) refreshPayment applies the provider status and never confirms '
      'without succeeded', () async {
    final b = await create();
    ok(await layer.bookings.startPayment(b.id, b.userId));
    final pending = ok(await layer.bookings.refreshPayment(b.id));
    expect(pending.booking.status, BookingStatus.pendingPayment);
    expect(pending.latestPayment!.status, PaymentStatus.pending);

    expect(fail(await layer.bookings.refreshPayment('nope')), isA<NotFound>());

    // The page confirms with a slow provider: refresh reads the status the
    // provider reports, and only `succeeded` confirms.
    gateway.outcome = const FakeOutcome.delay(Duration(milliseconds: 60));
    final s = ok(await layer.bookings.startPayment(b.id, b.userId));
    gateway.confirm(s.id, cardLast4: '1881');
    final mid = ok(await layer.bookings.refreshPayment(b.id));
    expect(mid.booking.status, BookingStatus.pendingPayment);
    await settle(150);
    expect((await get(b.id)).status, BookingStatus.confirmed);
    expect((await latest(b))!.status, PaymentStatus.succeeded);
  });

  test('(m) refreshPayment with no pending payment is refused', () async {
    final b = await create();
    expect(fail(await layer.bookings.refreshPayment(b.id)),
        isA<NoPendingPayment>());
  });

  test('(n) watchBooking emits after every write', () async {
    final b = await create();
    final seen = <BookingCheckoutState>[];
    final sub = layer.bookings.watchBooking(b.id).listen(seen.add);
    await settle(20);
    expect(seen.last.latestPayment, isNull);
    final s = ok(await layer.bookings.startPayment(b.id, b.userId));
    await settle(20);
    expect(seen.last.latestPayment!.status, PaymentStatus.pending);
    gateway.confirm(s.id, cardLast4: '4242');
    await settle();
    expect(seen.last.booking.status, BookingStatus.confirmed);
    expect(seen.last.latestPayment!.status, PaymentStatus.succeeded);
    await sub.cancel();
  });

  test('(o) after an extension, a failed or cancelled answer past the normal '
      'time expires at once; before it, the Hold carries on', () async {
    // Extended, then the failure arrives.
    final b = await create();
    final s = ok(await layer.bookings.startPayment(b.id, b.userId));
    env.advance(const Duration(minutes: 10));
    await layer.bookings.expireHolds();
    gateway.outcome = const FakeOutcome.fail();
    gateway.confirm(s.id, cardLast4: '4242');
    await settle();
    expect((await get(b.id)).status, BookingStatus.expired);

    // A cancel after an extension, on another slot.
    final b2 = await create(user: Ids.bookerExternal, slot: 20);
    final s2 = ok(await layer.bookings.startPayment(b2.id, b2.userId));
    env.advance(const Duration(minutes: 10));
    await layer.bookings.expireHolds();
    gateway.cancel(s2.id);
    await settle();
    expect((await get(b2.id)).status, BookingStatus.expired);

    // The same answer before the normal expiry: still pending, same expiry.
    final b3 = await create(slot: 21);
    final s3 = ok(await layer.bookings.startPayment(b3.id, b3.userId));
    env.advance(const Duration(minutes: 5));
    gateway.cancel(s3.id);
    await settle();
    final c3 = await get(b3.id);
    expect(c3.status, BookingStatus.pendingPayment);
    expect(c3.holdExpiresAt, b3.holdExpiresAt);
  });

  test('(p) changing the hold settings leaves a live Hold alone and applies '
      'to the next booking', () async {
    final b = await create();
    for (final (k, v) in [
      (SettingKeys.holdMinutes, 3),
      (SettingKeys.holdMaxMinutes, 6),
    ]) {
      await layer.settings.set(k, v, const SettingScope.university(),
          actorId: 'admin');
    }
    final same = await get(b.id);
    expect(same.holdExpiresAt, b.holdExpiresAt);
    expect(same.holdMaxExpiresAt, b.holdMaxExpiresAt);
    final next = await create(user: Ids.bookerExternal, slot: 20);
    expect(next.holdExpiresAt, env.now.add(const Duration(minutes: 3)));
    expect(next.holdMaxExpiresAt, env.now.add(const Duration(minutes: 6)));
  });

  test('(q) a restored snapshot re-attaches the pending payment and applies '
      'its outcome without a second payment', () async {
    final b = await create();
    ok(await layer.bookings.startPayment(b.id, b.userId));
    gateway.outcome = const FakeOutcome.fail();
    final snap = layer.toSnapshot();

    final restored = InMemoryDataLayer.fromSnapshot(
      clock: env.layer.clock,
      snapshot: snap,
      paymentDelay: Duration.zero,
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final all = await restored.payments.payments(b.id);
    expect(all, hasLength(1));
    expect(all.single.status, PaymentStatus.failed);
    expect(ok(await restored.bookings.get(b.id)).status,
        BookingStatus.pendingPayment);
  });
}

/// The seed has one live hold of its own (see `seed_bookings.dart`).
const _seedPendingCount = 1;

class Notification0 {
  Notification0(this.type, this.payload);
  final String type;
  final Map<String, String> payload;
}
