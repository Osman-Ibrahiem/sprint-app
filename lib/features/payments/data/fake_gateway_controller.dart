import 'dart:async';

import 'package:sprint/features/payments/domain/payment_provider.dart';

/// What the fake provider does once the simulated page confirms (R5). It is a
/// demo setting, chosen on `/demo` so every branch can be shown on purpose.
class FakeOutcome {
  const FakeOutcome._(this.name, this.delay);

  /// Succeeds after the short base delay.
  const FakeOutcome.succeed() : this._('succeed', null);

  /// Fails after the short base delay.
  const FakeOutcome.fail() : this._('fail', null);

  /// Succeeds after [delay] instead of the base delay.
  const FakeOutcome.delay(Duration delay) : this._('delay', delay);

  final String name;
  final Duration? delay;

  Map<String, Object?> toJson() =>
      {'kind': name, if (delay != null) 'delayMs': delay!.inMilliseconds};

  factory FakeOutcome.fromJson(Map<String, Object?> j) => switch (j['kind']) {
        'fail' => const FakeOutcome.fail(),
        'delay' =>
          FakeOutcome.delay(Duration(milliseconds: (j['delayMs']! as num).toInt())),
        _ => const FakeOutcome.succeed(),
      };

  @override
  bool operator ==(Object other) =>
      other is FakeOutcome && other.name == name && other.delay == delay;

  @override
  int get hashCode => Object.hash(name, delay);

  @override
  String toString() => 'FakeOutcome($name${delay == null ? '' : ', $delay'})';
}

/// What the simulated provider page shows about a session.
class FakeSessionView {
  const FakeSessionView({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.settled,
  });
  final String id;
  final String bookingId;

  /// Whole Egyptian pounds.
  final int amount;

  /// True once the provider has given its final answer.
  final bool settled;
}

class _Session {
  _Session(this.id, this.bookingId, this.amount);
  final String id;
  final String bookingId;
  final int amount;
  final Completer<PaymentUpdate> done = Completer<PaymentUpdate>();
  bool paying = false;
  Timer? timer;

  PaymentUpdate get latest =>
      _result ?? const PaymentUpdate(PaymentStatus.pending);
  PaymentUpdate? _result;

  void settle(PaymentUpdate u) {
    if (done.isCompleted) return;
    _result = u;
    timer?.cancel();
    done.complete(u);
  }
}

/// Fake only. The simulated provider page and `/demo` drive the fake
/// provider through this; booking code never imports it (BR-28, FR-009). The
/// only card data it ever sees is the last four digits.
class FakeGatewayController {
  FakeGatewayController({
    this.baseDelay = const Duration(milliseconds: 600),
    this.outcome = const FakeOutcome.succeed(),
  });

  /// How long the provider takes to answer after the page confirms.
  final Duration baseDelay;

  FakeOutcome outcome;

  final Map<String, _Session> _sessions = {};

  /// Called by the fake provider when a payment starts.
  void register(String id, String bookingId, int amount) {
    _sessions[id] = _Session(id, bookingId, amount);
  }

  /// A session that is not known (the app restarted since it was opened) is
  /// re-simulated from now by the current outcome (R5, demo only).
  _Session _ensure(String id, String bookingId) {
    final known = _sessions[id];
    if (known != null) return known;
    final s = _Session(id, bookingId, 0);
    _sessions[id] = s;
    _answer(s, cardLast4: '4242');
    return s;
  }

  FakeSessionView? session(String id) {
    final s = _sessions[id];
    return s == null
        ? null
        : FakeSessionView(
            id: s.id,
            bookingId: s.bookingId,
            amount: s.amount,
            settled: s.done.isCompleted,
          );
  }

  /// The page confirmed with a card whose last four digits are [cardLast4].
  void confirm(String sessionId, {required String cardLast4}) {
    final s = _sessions[sessionId];
    if (s == null || s.paying || s.done.isCompleted) return;
    _answer(s, cardLast4: cardLast4);
  }

  /// The booker backed out on the provider page (BR-47).
  void cancel(String sessionId) {
    final s = _sessions[sessionId];
    if (s == null || s.done.isCompleted) return;
    s.settle(const PaymentUpdate(PaymentStatus.cancelled));
  }

  void _answer(_Session s, {required String cardLast4}) {
    s.paying = true;
    final o = outcome;
    final wait = o.delay ?? baseDelay;
    s.timer = Timer(wait, () {
      s.settle(
        o.name == 'fail'
            ? const PaymentUpdate(PaymentStatus.failed)
            : PaymentUpdate(PaymentStatus.succeeded, cardLast4: cardLast4),
      );
    });
  }

  Future<PaymentUpdate> doneOf(PaymentSession session) =>
      _ensure(session.id, session.bookingId).done.future;

  PaymentUpdate latestOf(PaymentSession session) =>
      _ensure(session.id, session.bookingId).latest;
}
