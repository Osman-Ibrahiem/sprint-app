import 'dart:async';

import 'package:sprint/core/data/change_signal.dart';
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

  Map<String, Object?> toJson() => {
    'kind': name,
    if (delay != null) 'delayMs': delay!.inMilliseconds,
  };

  factory FakeOutcome.fromJson(Map<String, Object?> j) => switch (j['kind']) {
    'fail' => const FakeOutcome.fail(),
    'delay' => FakeOutcome.delay(
      Duration(milliseconds: (j['delayMs']! as num).toInt()),
    ),
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
class FakeGatewayController with ChangeSignal {
  FakeGatewayController({
    this.baseDelay = const Duration(milliseconds: 600),
    FakeOutcome outcome = const FakeOutcome.succeed(),
    Map<String, String> confirmed = const {},
    // ignore: prefer_initializing_formals
  }) : _outcome = outcome,
       _confirmed = Map.of(confirmed);

  /// How long the provider takes to answer after the page confirms.
  final Duration baseDelay;

  FakeOutcome _outcome;

  /// The demo outcome. Changing it fires [changes], so the demo snapshot is
  /// saved with the choice.
  FakeOutcome get outcome => _outcome;
  set outcome(FakeOutcome value) {
    if (value == _outcome) return;
    _outcome = value;
    notifyChanged();
  }

  final Map<String, _Session> _sessions = {};

  /// Called by the fake provider when a payment starts.
  void register(String id, String bookingId, int amount) {
    _sessions[id] = _Session(id, bookingId, amount);
  }

  /// Sessions the page confirmed and that have no answer yet, with the last
  /// four digits the page reported. Saved in the demo snapshot so a restart
  /// can tell a confirmed payment from an abandoned page (walk 2026-11-18 D2).
  final Map<String, String> _confirmed;

  /// What the snapshot saves: confirmed sessions still waiting for an answer.
  Map<String, String> get confirmedSessions => Map.unmodifiable(_confirmed);

  /// A session that is not known (the app restarted since it was opened).
  /// If the page had confirmed it, the answer is simulated again from now by
  /// the current outcome. If not, the booker left the provider page, which is
  /// a cancel (BR-47): the Hold keeps running and the payment screen offers
  /// to pay again. A card that was never entered is never charged.
  _Session _ensure(String id, String bookingId) {
    final known = _sessions[id];
    if (known != null) return known;
    final s = _Session(id, bookingId, 0);
    _sessions[id] = s;
    final last4 = _confirmed[id];
    if (last4 != null) {
      _answer(s, cardLast4: last4);
    } else {
      _settle(s, const PaymentUpdate(PaymentStatus.cancelled));
    }
    return s;
  }

  void _settle(_Session s, PaymentUpdate u) {
    s.settle(u);
    if (_confirmed.remove(s.id) != null) notifyChanged();
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
    _confirmed[sessionId] = cardLast4;
    notifyChanged();
    _answer(s, cardLast4: cardLast4);
  }

  /// The booker backed out on the provider page (BR-47).
  void cancel(String sessionId) {
    final s = _sessions[sessionId];
    if (s == null || s.done.isCompleted) return;
    _settle(s, const PaymentUpdate(PaymentStatus.cancelled));
  }

  void _answer(_Session s, {required String cardLast4}) {
    s.paying = true;
    final o = outcome;
    final wait = o.delay ?? baseDelay;
    s.timer = Timer(wait, () {
      _settle(
        s,
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
