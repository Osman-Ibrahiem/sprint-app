import 'dart:async';

import 'package:clock/clock.dart';
import 'package:sprint/core/data/change_signal.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/attendance/domain/attendance.dart';
import 'package:sprint/features/attendance/domain/attendance_repository.dart';
import 'package:sprint/features/booking/domain/availability_service.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_quote.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/booking/domain/cancellation_policy.dart';
import 'package:sprint/features/booking/domain/conflict_checker.dart';
import 'package:sprint/features/booking/domain/hold_policy.dart';
import 'package:sprint/features/booking/domain/pricing_service.dart';
import 'package:sprint/features/booking/domain/qr_token.dart';
import 'package:sprint/features/booking/domain/unit_settings.dart';
import 'package:sprint/features/catalogue/domain/bookable_unit.dart';
import 'package:sprint/features/catalogue/domain/catalogue_repository.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/identity/domain/identity_repository.dart';
import 'package:sprint/features/identity/domain/permission_checker.dart';
import 'package:sprint/features/verification/domain/verification_repository.dart';
import 'package:sprint/features/notifications/domain/notification.dart';
import 'package:sprint/features/notifications/domain/notification_repository.dart';
import 'package:sprint/features/payments/domain/payment.dart';
import 'package:sprint/features/payments/domain/payment_provider.dart';
import 'package:sprint/features/payments/domain/payment_repository.dart';
import 'package:sprint/features/payments/domain/refund.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';
import 'package:sprint/features/settings/domain/settings_repository.dart';

/// Enforces the same rules the backend will: permissions, availability,
/// conflicts, pricing, holds, cancellation and refunds. Every write runs in a
/// serial queue, so two "simultaneous" creates for the last place cannot both
/// win (BR-11, research R8).
class InMemoryBookingRepository with ChangeSignal implements BookingRepository {
  InMemoryBookingRepository({
    required Iterable<Booking> seed,
    required this.catalogue,
    required this.settings,
    required this.identity,
    required this.verification,
    required this.payments,
    required this.notifications,
    required this.attendance,
    required this.paymentProvider,
    required this.paymentProviderName,
    required this.clock,
    this.availability = const AvailabilityService(),
    this.conflicts = const ConflictChecker(),
    this.pricing = const PricingService(),
    this.holds = const HoldPolicy(),
    this.cancellation = const CancellationPolicy(),
    this.permissions = const PermissionChecker(),
    this.applyOffers = false,
  }) : _bookings = {for (final b in seed) b.id: b} {
    for (final b in seed) {
      final n = int.tryParse(b.code.replaceAll(RegExp('[^0-9]'), ''));
      if (n != null && n >= _nextCode) _nextCode = n + 1;
      // Restored snapshots keep their `bk-new-N` ids; new ones must not clash.
      final m = RegExp(r'^bk-new-(\d+)$').firstMatch(b.id);
      final k = m == null ? null : int.parse(m.group(1)!);
      if (k != null && k >= _nextId) _nextId = k + 1;
    }
  }

  final CatalogueRepository catalogue;
  final SettingsRepository settings;
  final IdentityRepository identity;
  final VerificationRepository verification;
  final PaymentRepository payments;
  final NotificationRepository notifications;
  final AttendanceRepository attendance;
  final PaymentProvider paymentProvider;
  final String paymentProviderName;
  final Clock clock;
  final AvailabilityService availability;
  final ConflictChecker conflicts;
  final PricingService pricing;
  final HoldPolicy holds;
  final CancellationPolicy cancellation;
  final PermissionChecker permissions;

  /// Offers (BR-20) are priced in only when this is on. Off until the offers
  /// feature shows them (decisions.md 2026-11-17), so the summary never shows
  /// a price the schedule did not.
  final bool applyOffers;

  final Map<String, Booking> _bookings;
  int _nextCode = 1001;
  int _nextId = 1;
  Future<void> _tail = Future<void>.value();

  /// Runs [op] after every earlier write has finished.
  Future<T> _serial<T>(Future<T> Function() op, {bool notify = true}) {
    final run = _tail.then((_) async {
      final result = await op();
      if (notify) notifyChanged();
      return result;
    });
    _tail = run.then<void>((_) {}, onError: (_) {});
    return run;
  }

  /// Everything, for the demo snapshot.
  List<Booking> get allBookings => _bookings.values.toList();

  /// All bookings of a unit, for availability.
  Future<List<Booking>> bookingsForUnit(String unitId) => _serial(
        () async {
          // A Hold that ran out is released (or extended) before availability
          // reads it, so a stale Hold never shows a place as taken or free.
          if (await _applyHolds() > 0) notifyChanged();
          return _bookings.values.where((b) => b.unitId == unitId).toList();
        },
        notify: false,
      );

  Future<PermissionSubject> _subject(String userId) async => PermissionSubject(
        userId: userId,
        assignments: await identity.roleAssignments(userId),
      );

  Future<PermissionTarget> _target(Booking b) async {
    final facility = await catalogue.getFacility(b.facilityId);
    String? trainerUser;
    if (b.trainerId != null) {
      for (final t in await catalogue.trainers(b.facilityId)) {
        if (t.id == b.trainerId) trainerUser = t.userId;
      }
    }
    return PermissionTarget(
      owningUnitId: facility?.owningUnitId,
      facilityId: b.facilityId,
      trainerUserId: trainerUser,
    );
  }

  Future<UnitSettings> _settingsFor(Booking b) => UnitSettings.resolve(
        settings,
        unitId: b.unitId,
        facilityId: b.facilityId,
      );

  // ----------------------------------------------------------------- create

  @override
  Future<Result<Booking>> create(BookingRequest request) =>
      _serial(() => _create(request));

  @override
  Future<Result<BookingQuote>> quote(BookingRequest request) => _serial(
        () async {
          final checked = await _check(request);
          if (checked is Err<_Checked>) return Err(checked.failure);
          final c = (checked as Ok<_Checked>).value;
          return Ok(BookingQuote(
            facilityId: c.facility.id,
            unitId: c.unit.id,
            trainerId: c.trainerId,
            start: request.start,
            end: request.end,
            tier: c.tier,
            amount: c.quote.amount,
            mode: c.cfg.bookingMode,
            maxParticipants: c.cfg.maxParticipants,
            cancellationCutoffHours: c.cfg.cancellationCutoffHours,
            refundPercent: c.cfg.refundPercent,
          ));
        },
        notify: false,
      );

  /// Every check of a booking request, shared by [quote] and [create] so the
  /// two can never drift (research R6). Order: permission, unit and facility,
  /// trainer, structure, own overlap, cap, places, price.
  Future<Result<_Checked>> _check(BookingRequest r) async {
    await _applyHolds();
    final now = clock.now();
    final userId = r.userId;
    if (userId == null) return const Err(NotPermitted());
    final user = await identity.getUser(userId);
    if (user == null) return const Err(NotPermitted());
    final subject = await _subject(userId);

    final BookableUnit? unit = await catalogue.getUnit(r.unitId);
    if (unit == null) return const Err(NotFound('unit'));
    final Facility? facility = await catalogue.getFacility(unit.facilityId);
    if (facility == null || !facility.isPublished) {
      return const Err(NotFound('facility'));
    }
    if (!permissions.can(
      subject,
      AppAction.book,
      PermissionTarget(
        owningUnitId: facility.owningUnitId,
        facilityId: facility.id,
      ),
    )) {
      return const Err(NotPermitted());
    }

    final cfg = await UnitSettings.resolve(
      settings,
      unitId: unit.id,
      facilityId: facility.id,
    );

    final trainers = await catalogue.trainers(facility.id);
    final trainer = r.trainerId == null
        ? null
        : trainers.where((t) => t.id == r.trainerId).firstOrNull;
    if (facility.requiresTrainer && trainer == null) {
      return const Err(NotFound('trainer'));
    }

    // Opening hours, closures, window, past, grid and range (BR-05 – BR-09).
    final structural = availability.checkRequest(
      facility: facility,
      unit: unit,
      hours: [
        ...await catalogue.hours(unit.id),
        ...await catalogue.hours(facility.id),
      ],
      closures: await catalogue.closures(facilityId: facility.id, unitId: unit.id),
      settings: cfg,
      now: now,
      start: r.start,
      end: r.end,
      trainer: trainer,
      trainerAvailability: trainer == null
          ? const []
          : await catalogue.trainerAvailability(trainer.id, unitId: unit.id),
    );
    if (structural != null) {
      // The maximum is a rule of the range path only (BR-08). More than one
      // slot where one is allowed is refused without a number, because the
      // limit there is the single slot.
      final rangePath = facility.isFree && !facility.requiresTrainer;
      return Err(
        structural is RangeTooLong && rangePath
            ? RangeTooLong(maxHours: cfg.maxRangeHours)
            : structural,
      );
    }

    // Overlaps, capacity and limits, slot by slot (BR-11, BR-08).
    final seats = cfg.bookingMode == BookingMode.exclusive ? 1 : r.seats;
    final clash = conflicts.check(
      proposal: BookingProposal(
        userId: userId,
        unitId: unit.id,
        start: r.start,
        end: r.end,
        seats: seats,
        trainerId: trainer?.id,
        slotMinutes: facility.requiresTrainer
            ? cfg.sessionMinutes
            : cfg.slotGranularityMinutes,
      ),
      existing: _bookings.values.toList(),
      settings: cfg,
      now: now,
      trainerCapacity: trainer?.trainerCapacity,
    );
    if (clash != null) return Err(clash);

    // Price: the tier comes from verification now and is frozen (BR-17).
    final tier = await verification.tierFor(userId, now);
    final quoted = pricing.quote(
      facility: facility,
      prices: await catalogue.prices(unit.id),
      tier: tier,
      mode: cfg.bookingMode,
      start: r.start,
      seats: seats,
      offers: applyOffers
          ? await catalogue.offers(facilityId: facility.id, unitId: unit.id)
          : const [],
    );
    if (quoted is Err<PriceQuote>) return Err(quoted.failure);
    return Ok(_Checked(
      now: now,
      userId: userId,
      unit: unit,
      facility: facility,
      trainerId: trainer?.id,
      cfg: cfg,
      seats: seats,
      tier: tier,
      quote: (quoted as Ok<PriceQuote>).value,
    ));
  }

  Future<Result<Booking>> _create(BookingRequest r) async {
    final checked = await _check(r);
    if (checked is Err<_Checked>) return Err(checked.failure);
    final c = (checked as Ok<_Checked>).value;
    final quote = c.quote;

    final id = 'bk-new-${_nextId++}';
    final code = 'SP-${_nextCode++}';
    final booking = Booking(
      id: id,
      code: code,
      userId: c.userId,
      facilityId: c.facility.id,
      unitId: c.unit.id,
      trainerId: c.trainerId,
      start: r.start,
      end: r.end,
      seats: c.seats,
      tierAtBooking: c.tier,
      priceAtBooking: quote.amount,
      // Free bookings confirm at once (BR-19); paid ones hold the place until
      // the provider answers (BR-12, BR-28).
      status: quote.requiresPayment
          ? BookingStatus.pendingPayment
          : BookingStatus.confirmed,
      qrToken: qrTokenFor(id, code),
      // Frozen now, so later settings changes never touch a live Hold
      // (BR-12, BR-46).
      holdStartedAt: quote.requiresPayment ? c.now : null,
      holdExpiresAt: quote.requiresPayment
          ? holds.expiryFrom(
              c.now,
              holdMinutes: c.cfg.holdMinutes,
              start: r.start,
            )
          : null,
      holdMaxExpiresAt: quote.requiresPayment
          ? holds.maxExpiryFrom(
              c.now,
              holdMinutes: c.cfg.holdMinutes,
              holdMaxMinutes: c.cfg.holdMaxMinutes,
              start: r.start,
            )
          : null,
    );
    _bookings[id] = booking;
    if (!quote.requiresPayment) {
      await _notify(booking.userId, 'booking.confirmed', booking);
    }
    return Ok(booking);
  }

  // ---------------------------------------------------------------- payment

  /// The provider subscription of each pending payment, by payment id.
  final Map<String, StreamSubscription<PaymentUpdate>> _watching = {};
  final Map<String, PaymentSession> _sessions = {};

  @override
  Future<Result<PaymentSession>> startPayment(String bookingId, String userId) =>
      _serial(() => _startPayment(bookingId, userId));

  Future<Result<PaymentSession>> _startPayment(
    String bookingId,
    String userId,
  ) async {
    await _applyHolds();
    final b = _bookings[bookingId];
    if (b == null) return const Err(NotFound('booking'));
    if (b.userId != userId) return const Err(NotPermitted());
    if (b.status == BookingStatus.expired) return const Err(HoldExpired());
    if (b.status != BookingStatus.pendingPayment) {
      return const Err(InvalidTransition());
    }

    // One pending payment per booking: hand back its session (data-model).
    final current = await payments.latestPayment(b.id);
    if (current != null && current.status == PaymentStatus.pending) {
      final session = _sessions[current.id] ??
          paymentProvider.sessionFor(current);
      _attach(current, session);
      return Ok(session);
    }

    final facility = await catalogue.getFacility(b.facilityId);
    final PaymentSession session;
    try {
      session = await paymentProvider.start(
        PaymentRequest(
          amount: b.priceAtBooking,
          bookingId: b.id,
          owningUnitId: facility!.owningUnitId,
        ),
      );
    } on Object {
      return const Err(PaymentUnavailable());
    }
    final payment = Payment(
      id: 'pay-${session.id}',
      bookingId: b.id,
      provider: paymentProviderName,
      providerRef: session.id,
      amount: b.priceAtBooking,
      status: PaymentStatus.pending,
      startedAt: clock.now(),
      owningUnitId: facility.owningUnitId, // BR-33
    );
    await payments.savePayment(payment);
    _attach(payment, session);
    return Ok(session);
  }

  /// Listens to the provider for [payment]. The repository, not a screen,
  /// applies every answer, as a backend webhook will (BR-28).
  void _attach(Payment payment, PaymentSession session) {
    if (_watching.containsKey(payment.id)) return;
    _sessions[payment.id] = session;
    _watching[payment.id] = paymentProvider.watch(session).listen((u) {
      if (u.status != PaymentStatus.pending) {
        unawaited(_serial(() => _applyOutcome(payment.id, payment.bookingId, u)));
      }
    });
  }

  /// After a restart: watch again every payment still pending (FR-024).
  Future<void> resumePendingPayments() async {
    for (final b in _bookings.values.toList()) {
      final p = await payments.latestPayment(b.id);
      if (p != null && p.status == PaymentStatus.pending) {
        _attach(p, paymentProvider.sessionFor(p));
      }
    }
  }

  /// The webhook analogue (contracts/repositories.md table). Runs in the
  /// serial queue; a payment that already has its final answer is left alone.
  Future<void> _applyOutcome(
    String paymentId,
    String bookingId,
    PaymentUpdate update,
  ) async {
    final all = await payments.payments(bookingId);
    final payment = all.where((p) => p.id == paymentId).firstOrNull;
    if (payment == null || payment.status != PaymentStatus.pending) return;
    unawaited(_watching.remove(paymentId)?.cancel());
    _sessions.remove(paymentId);

    // The Hold is judged first, with the payment still pending: it may just
    // have run out, or reached its maximum (BR-46).
    await _applyHolds();
    var b = _bookings[bookingId];
    final now = clock.now();

    switch (update.status) {
      case PaymentStatus.succeeded:
        final number = await payments.nextReceiptNumber(CairoTime.toCairo(now));
        final paid = payment.copyWith(
          status: PaymentStatus.succeeded,
          paidAt: now,
          cardLast4: update.cardLast4,
          receiptNumber: number,
        );
        await payments.savePayment(paid);
        if (b != null && b.status == BookingStatus.pendingPayment) {
          // Only the provider's answer confirms (BR-28).
          b = (b.confirm() as Ok<Booking>).value;
          _bookings[bookingId] = b;
          await _notify(b.userId, 'booking.confirmed', b);
        } else if (b != null) {
          // Late: the booking is gone, so the money goes back in full and the
          // booking is never re-confirmed (BR-46).
          final refund = await paymentProvider.refund(paid, paid.amount);
          await payments.saveRefund(
            Refund(
              id: 'rf-${paid.id}',
              paymentId: paid.id,
              amount: refund.amount,
              reason: 'late_confirmation',
              status: refund.succeeded
                  ? RefundStatus.succeeded
                  : RefundStatus.failed,
            ),
          );
          await _notify(
            b.userId,
            'payment.refunded_auto',
            b,
            extra: {'amount': '${refund.amount}'},
          );
        }
      case PaymentStatus.failed || PaymentStatus.cancelled:
        await payments.savePayment(payment.copyWith(status: update.status));
        // The Hold carries on (US-10, BR-47) unless it had been extended and
        // its normal time is over: the extension buys no retry time (BR-46).
        if (b != null &&
            b.status == BookingStatus.pendingPayment &&
            holds.expiresOnAnswer(b, now)) {
          _bookings[bookingId] = (b.expire() as Ok<Booking>).value;
        }
      case PaymentStatus.pending:
        break;
    }
  }

  @override
  Future<Result<BookingCheckoutState>> refreshPayment(String bookingId) =>
      _serial(() async {
        final b = _bookings[bookingId];
        if (b == null) return const Err(NotFound('booking'));
        final p = await payments.latestPayment(bookingId);
        if (p == null || p.status != PaymentStatus.pending) {
          return const Err(NoPendingPayment());
        }
        final session = _sessions[p.id] ?? paymentProvider.sessionFor(p);
        final update = await paymentProvider.status(session);
        // Applies what the provider says; it never confirms by itself.
        if (update.status != PaymentStatus.pending) {
          await _applyOutcome(p.id, bookingId, update);
        }
        return Ok(await _state(bookingId));
      });

  @override
  Future<Result<Booking>> leaveCheckout(String bookingId, String userId) =>
      _serial(() async {
        final b = _bookings[bookingId];
        if (b == null) return const Err(NotFound('booking'));
        if (b.userId != userId) return const Err(NotPermitted());
        if (b.status == BookingStatus.expired) return Ok(b);
        if (b.status != BookingStatus.pendingPayment) {
          return const Err(InvalidTransition());
        }
        // BR-47: the place goes back now. A payment still pending stays
        // watched, so a late success is refunded.
        final expired = (b.expire() as Ok<Booking>).value;
        _bookings[bookingId] = expired;
        return Ok(expired);
      });

  Future<BookingCheckoutState> _state(String bookingId) async {
    final booking = _bookings[bookingId]!;
    final payment = await payments.latestPayment(bookingId);
    final refund = payment == null
        ? null
        : (await payments.refunds(payment.id)).firstOrNull;
    return BookingCheckoutState(
      booking: booking,
      latestPayment: payment,
      refund: refund,
    );
  }

  @override
  Stream<BookingCheckoutState> watchBooking(String bookingId) {
    StreamSubscription<void>? sub;
    late final StreamController<BookingCheckoutState> out;
    Future<void> emit() async {
      if (!_bookings.containsKey(bookingId) || out.isClosed) return;
      final state = await _state(bookingId);
      if (!out.isClosed) out.add(state);
    }

    out = StreamController<BookingCheckoutState>(
      onListen: () {
        unawaited(emit());
        sub = changes.listen((_) => unawaited(emit()));
      },
      onCancel: () async {
        await sub?.cancel();
        await out.close();
      },
    );
    return out.stream;
  }

  // ----------------------------------------------------------------- cancel

  @override
  Future<Result<Booking>> cancel(
    String id,
    String actorUserId, {
    String? reason,
  }) =>
      _serial(() => _cancel(id, actorUserId, reason));

  Future<Result<Booking>> _cancel(String id, String actorId, String? reason) async {
    final b = _bookings[id];
    if (b == null) return const Err(NotFound('booking'));

    final isOwner = b.userId == actorId;
    final isAdmin = permissions.can(
      await _subject(actorId),
      AppAction.cancelAsAdmin,
      await _target(b),
    );
    if (!isOwner && !isAdmin) return const Err(NotPermitted());
    final by = isOwner ? CancelledBy.owner : CancelledBy.admin;

    final cfg = await _settingsFor(b);
    final paid = (await payments.payments(b.id))
        .where((p) => p.status == PaymentStatus.succeeded)
        .toList();
    final paidAmount = paid.fold<int>(0, (sum, p) => sum + p.amount);

    final decision = cancellation.decide(
      booking: b,
      now: clock.now(),
      by: by,
      cutoffHours: cfg.cancellationCutoffHours,
      refundPercent: cfg.refundPercent,
      paidAmount: paidAmount,
    );
    if (decision is Err<CancellationDecision>) return Err(decision.failure);
    final refundAmount = (decision as Ok<CancellationDecision>).value.refundAmount;

    final cancelled = (b.cancel(by, reason: reason) as Ok<Booking>).value;
    _bookings[id] = cancelled;

    if (refundAmount > 0 && paid.isNotEmpty) {
      final payment = paid.first;
      final result = await paymentProvider.refund(payment, refundAmount);
      await payments.saveRefund(
        Refund(
          id: 'rf-${payment.id}',
          paymentId: payment.id,
          amount: result.amount,
          reason: reason ?? (by == CancelledBy.admin ? 'admin' : 'owner'),
          status: result.succeeded ? RefundStatus.succeeded : RefundStatus.failed,
        ),
      );
    }
    if (by == CancelledBy.admin) {
      await _notify(b.userId, 'booking.cancelled_by_admin', cancelled); // BR-41
    }
    return Ok(cancelled);
  }

  // ------------------------------------------------------------- attendance

  @override
  Future<Result<Booking>> markAttendance(
    String id,
    AttendanceMethod method,
    String actorUserId,
  ) =>
      _serial(() => _markAttendance(id, method, actorUserId));

  Future<Result<Booking>> _markAttendance(
    String id,
    AttendanceMethod method,
    String actorId,
  ) async {
    final b = _bookings[id];
    if (b == null) return const Err(NotFound('booking'));
    if (!permissions.can(
      await _subject(actorId),
      AppAction.scanAttendance,
      await _target(b),
    )) {
      return const Err(NotPermitted());
    }
    if (b.status != BookingStatus.confirmed) return const Err(InvalidTransition());

    final cfg = await _settingsFor(b);
    final now = clock.now();
    final opens = b.start.subtract(Duration(minutes: cfg.checkInOpensMinutes));
    if (now.isBefore(opens) || !now.isBefore(b.end)) {
      return const Err(CheckInClosed()); // BR-35
    }

    final attended = (b.attend() as Ok<Booking>).value;
    _bookings[id] = attended;
    await attendance.save(
      Attendance(
        bookingId: id,
        status: AttendanceStatus.present,
        method: method, // manual entries are flagged (BR-34)
        markedBy: actorId,
        markedAt: now,
      ),
    );
    return Ok(attended);
  }

  // ------------------------------------------------------------ housekeeping

  @override
  Future<int> expireHolds() => _serial(_applyHolds);

  /// BR-12 + BR-46 for every pending booking: extend once while a payment is
  /// pending, otherwise expire. Returns how many expired. Callers run it in
  /// the serial queue.
  Future<int> _applyHolds() async {
    final now = clock.now();
    var expired = 0;
    for (final b in _bookings.values.toList()) {
      if (b.status != BookingStatus.pendingPayment) continue;
      final pending = (await payments.latestPayment(b.id))?.status ==
          PaymentStatus.pending;
      switch (holds.nextExpiry(b, now, hasPendingPayment: pending)) {
        case HoldKeep():
          break;
        case HoldExtend(:final to):
          final r = b.extendHoldTo(to);
          if (r is Ok<Booking>) _bookings[b.id] = r.value;
        case HoldExpire():
          _bookings[b.id] = (b.expire() as Ok<Booking>).value;
          expired++;
      }
    }
    return expired;
  }

  @override
  Future<int> markNoShows() => _serial(() async {
        final now = clock.now();
        var n = 0;
        for (final b in _bookings.values.toList()) {
          final r = b.markNoShow(now);
          if (r is Ok<Booking>) {
            _bookings[b.id] = r.value; // no penalty: only the status changes
            await attendance.save(
              Attendance(
                bookingId: b.id,
                status: AttendanceStatus.noShow,
                method: AttendanceMethod.auto,
                markedBy: 'system',
                markedAt: now,
              ),
            );
            n++;
          }
        }
        return n;
      });

  // ------------------------------------------------------------------ reads

  @override
  Future<Result<Booking>> get(String id) async {
    final b = _bookings[id];
    return b == null ? const Err(NotFound('booking')) : Ok(b);
  }

  @override
  Future<List<Booking>> listForUser(String userId, {bool upcoming = false}) async {
    final now = clock.now();
    return _bookings.values
        .where((b) => b.userId == userId && (!upcoming || b.end.isAfter(now)))
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  @override
  Future<List<Booking>> listForFacility(
    String facilityId, {
    DateTime? from,
    DateTime? to,
  }) async =>
      _bookings.values
          .where((b) =>
              b.facilityId == facilityId &&
              (from == null || b.end.isAfter(from)) &&
              (to == null || b.start.isBefore(to)))
          .toList()
        ..sort((a, b) => a.start.compareTo(b.start));

  Future<void> _notify(
    String userId,
    String type,
    Booking b, {
    Map<String, String> extra = const {},
  }) =>
      notifications.push(
        Notification(
          id: 'nt-${clock.now().microsecondsSinceEpoch}-${b.id}-$type',
          userId: userId,
          type: type,
          payload: {'code': b.code, ...extra},
          sentAt: clock.now(),
        ),
      );

  // ------------------------------------------------------------------ BR-04

  /// Refuses a mode change or a capacity cut that existing future bookings
  /// would break (BR-04). Install it on the settings repository.
  Future<Failure?> settingChangeGuard(
    SettingKey<dynamic> key,
    Object? value,
    SettingScope scope,
  ) async {
    if (scope.type != SettingScopeType.unit) return null;
    final unitId = scope.id!;
    final now = clock.now();
    final future = _bookings.values
        .where((b) =>
            b.unitId == unitId && b.holdsPlace(now) && b.end.isAfter(now))
        .toList();
    if (future.isEmpty) return null;

    if (key.name == SettingKeys.bookingMode.name) {
      final current = await settings.resolve(SettingKeys.bookingMode, unitId: unitId);
      if (current != value) {
        return Conflict('${future.length} future bookings exist on this unit');
      }
    }
    if (key.name == SettingKeys.capacity.name && value is int) {
      var peak = 0;
      for (final b in future) {
        final seats = future
            .where((o) => o.overlaps(b.start, b.end))
            .fold<int>(0, (s, o) => s + o.seats);
        if (seats > peak) peak = seats;
      }
      if (peak > value) return Conflict('$peak places are already booked');
    }
    return null;
  }
}

/// A request that passed every check, with what the checks resolved.
class _Checked {
  const _Checked({
    required this.now,
    required this.userId,
    required this.unit,
    required this.facility,
    required this.trainerId,
    required this.cfg,
    required this.seats,
    required this.tier,
    required this.quote,
  });

  final DateTime now;
  final String userId;
  final BookableUnit unit;
  final Facility facility;
  final String? trainerId;
  final UnitSettings cfg;
  final int seats;
  final PriceTier tier;
  final PriceQuote quote;
}
