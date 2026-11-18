import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/payments/data/fake_gateway_controller.dart';
import 'package:sprint/features/payments/data/fake_payment_provider.dart';
import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/payments/domain/payment_provider.dart';

/// A second implementation, to prove callers cannot tell providers apart.
class _OtherProvider implements PaymentProvider {
  @override
  Future<PaymentSession> start(PaymentRequest request) async => PaymentSession(
        id: 'x-1',
        bookingId: request.bookingId,
        checkoutLocation: Uri.parse('https://gateway.example/x-1'),
      );

  @override
  PaymentSession sessionFor(Payment payment) => PaymentSession(
        id: payment.providerRef,
        bookingId: payment.bookingId,
        checkoutLocation: Uri.parse('https://gateway.example/${payment.providerRef}'),
      );

  @override
  Stream<PaymentUpdate> watch(PaymentSession session) => Stream.fromIterable(
      [const PaymentUpdate(PaymentStatus.pending), const PaymentUpdate(PaymentStatus.succeeded)]);

  @override
  Future<PaymentUpdate> status(PaymentSession session) async =>
      const PaymentUpdate(PaymentStatus.succeeded);

  @override
  Future<RefundResult> refund(Payment payment, int amount) async =>
      RefundResult(reference: 'r-x', amount: amount, succeeded: true);
}

const _req =
    PaymentRequest(amount: 120, bookingId: 'b1', owningUnitId: 'ou1');

void main() {
  final payment = Payment(
    id: 'p1',
    bookingId: 'b1',
    provider: 'FAKE',
    providerRef: 'ref',
    amount: 120,
    status: PaymentStatus.succeeded,
    startedAt: DateTime.utc(2026, 11, 18),
    owningUnitId: 'ou1',
  );

  /// Collects what `watch` yields.
  List<PaymentUpdate> collect(PaymentProvider p, PaymentSession s) {
    final out = <PaymentUpdate>[];
    p.watch(s).listen(out.add);
    return out;
  }

  test('start gives a session whose location is the in-app sandbox page', () {
    fakeAsync((async) {
      final p = FakePaymentProvider();
      late PaymentSession s;
      p.start(_req).then((v) => s = v);
      async.flushMicrotasks();
      expect(s.bookingId, 'b1');
      expect(s.id, isNotEmpty);
      expect(s.checkoutLocation.path, '/pay/sandbox/${s.id}');
    });
  });

  test('watch yields pending and nothing else until the page acts', () {
    fakeAsync((async) {
      final p = FakePaymentProvider();
      late PaymentSession s;
      p.start(_req).then((v) => s = v);
      async.flushMicrotasks();
      final seen = collect(p, s);
      async.elapse(const Duration(minutes: 5));
      expect(seen.map((u) => u.status), [PaymentStatus.pending]);
    });
  });

  test('confirm with outcome succeed: succeeded with the last four, after 600 ms',
      () {
    fakeAsync((async) {
      final p = FakePaymentProvider();
      late PaymentSession s;
      p.start(_req).then((v) => s = v);
      async.flushMicrotasks();
      final seen = collect(p, s);
      p.gateway.confirm(s.id, cardLast4: '4242');
      async.elapse(const Duration(milliseconds: 599));
      expect(seen.map((u) => u.status), [PaymentStatus.pending]);
      async.elapse(const Duration(milliseconds: 2));
      expect(seen.last, const PaymentUpdate(PaymentStatus.succeeded, cardLast4: '4242'));
      expect(seen.length, 2);
    });
  });

  test('confirm with outcome fail: failed, no card digits', () {
    fakeAsync((async) {
      final p = FakePaymentProvider();
      p.gateway.outcome = const FakeOutcome.fail();
      late PaymentSession s;
      p.start(_req).then((v) => s = v);
      async.flushMicrotasks();
      final seen = collect(p, s);
      p.gateway.confirm(s.id, cardLast4: '4242');
      async.elapse(const Duration(seconds: 1));
      expect(seen.last, const PaymentUpdate(PaymentStatus.failed));
    });
  });

  test('confirm with outcome delay(d): succeeded only after d', () {
    fakeAsync((async) {
      final p = FakePaymentProvider();
      p.gateway.outcome = const FakeOutcome.delay(Duration(seconds: 30));
      late PaymentSession s;
      p.start(_req).then((v) => s = v);
      async.flushMicrotasks();
      final seen = collect(p, s);
      p.gateway.confirm(s.id, cardLast4: '1881');
      async.elapse(const Duration(seconds: 29));
      expect(seen.map((u) => u.status), [PaymentStatus.pending]);
      async.elapse(const Duration(seconds: 2));
      expect(seen.last.status, PaymentStatus.succeeded);
      expect(seen.last.cardLast4, '1881');
    });
  });

  test('cancel on the page: cancelled at once', () {
    fakeAsync((async) {
      final p = FakePaymentProvider();
      late PaymentSession s;
      p.start(_req).then((v) => s = v);
      async.flushMicrotasks();
      final seen = collect(p, s);
      p.gateway.cancel(s.id);
      async.flushMicrotasks();
      expect(seen.last, const PaymentUpdate(PaymentStatus.cancelled));
    });
  });

  test('status returns the latest update and never changes the payment', () {
    fakeAsync((async) {
      final p = FakePaymentProvider();
      late PaymentSession s;
      p.start(_req).then((v) => s = v);
      async.flushMicrotasks();
      PaymentUpdate? u;
      p.status(s).then((v) => u = v);
      async.flushMicrotasks();
      expect(u!.status, PaymentStatus.pending);
      p.gateway.confirm(s.id, cardLast4: '4242');
      async.elapse(const Duration(seconds: 1));
      p.status(s).then((v) => u = v);
      async.flushMicrotasks();
      expect(u, const PaymentUpdate(PaymentStatus.succeeded, cardLast4: '4242'));
    });
  });

  // Walk 2026-11-18 D2: after a restart, only a session the page confirmed
  // gets an answer by the outcome; an abandoned page is a cancel (BR-47).
  test('an unknown session the page never confirmed comes back cancelled, '
      'whatever the outcome', () {
    fakeAsync((async) {
      final p = FakePaymentProvider();
      final ghost = PaymentSession(
        id: 'FAKE-pay-77',
        bookingId: 'b9',
        checkoutLocation: Uri(path: '/pay/sandbox/FAKE-pay-77'),
      );
      PaymentUpdate? u;
      p.status(ghost).then((v) => u = v);
      async.flushMicrotasks();
      expect(u!.status, PaymentStatus.cancelled);
      expect(u!.cardLast4, isNull);
    });
  });

  test('an unknown session the page had confirmed re-simulates by the '
      'outcome with the reported last four', () {
    fakeAsync((async) {
      final p = FakePaymentProvider(
        controller: FakeGatewayController(
          baseDelay: const Duration(milliseconds: 600),
          outcome: const FakeOutcome.fail(),
          confirmed: const {'FAKE-pay-78': '1111', 'FAKE-pay-79': '2222'},
        ),
      );
      PaymentSession ghost(String id) => PaymentSession(
            id: id,
            bookingId: 'b9',
            checkoutLocation: Uri(path: '/pay/sandbox/$id'),
          );
      final failed = collect(p, ghost('FAKE-pay-78'));
      async.elapse(const Duration(seconds: 1));
      expect(failed.last.status, PaymentStatus.failed);

      p.gateway.outcome = const FakeOutcome.succeed();
      final paid = collect(p, ghost('FAKE-pay-79'));
      async.elapse(const Duration(seconds: 1));
      expect(paid.last.status, PaymentStatus.succeeded);
      expect(paid.last.cardLast4, '2222');
      expect(p.gateway.confirmedSessions, isEmpty);
    });
  });

  test('refund returns a successful result for the amount', () async {
    final p = FakePaymentProvider();
    final r = await p.refund(payment, 60);
    expect(r.succeeded, isTrue);
    expect(r.amount, 60);
    expect(r.reference, isNotEmpty);
  });

  test('a refund above the paid amount is refused', () async {
    final p = FakePaymentProvider();
    final r = await p.refund(payment, 121);
    expect(r.succeeded, isFalse);
  });

  test('a session belongs to its booking', () async {
    final p = FakePaymentProvider();
    final s = await p.start(
      const PaymentRequest(amount: 50, bookingId: 'bk-9', owningUnitId: 'ou1'),
    );
    expect(s.bookingId, 'bk-9');
    expect(p.gateway.session(s.id)!.amount, 50);
    expect(p.gateway.session(s.id)!.bookingId, 'bk-9');
    expect(p.gateway.session('nope'), isNull);
  });

  test('the caller cannot tell which provider answered (FR-025)', () async {
    final sa = await FakePaymentProvider().start(_req);
    final sb = await _OtherProvider().start(_req);
    expect(sa.runtimeType, sb.runtimeType);
    expect((await _OtherProvider().status(sb)).status, PaymentStatus.succeeded);
  });
}
