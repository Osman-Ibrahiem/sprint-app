import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/identity/domain/verification.dart';

import '../../helpers/data_env.dart';

/// SC-007, FR-041: no verification change touches a stored booking; a new
/// booking uses the tier at its own moment (FR-040).
void main() {
  late DataEnv env;
  setUp(() => env = DataEnv());

  Map<String, (PriceTier, int)> snapshot() => {
    for (final b in env.layer.bookings.allBookings)
      b.id: (b.tierAtBooking, b.priceAtBooking),
  };

  Future<Verification> decided(String id, VerificationStatus s) async {
    final v = (await env.layer.verification.history(id)).first;
    return v;
  }

  test('verification changes leave every seed booking unchanged', () async {
    final before = snapshot();
    expect(before, isNotEmpty);
    final repo = env.layer.verification;

    // Approve a pending request (Karim).
    final approve = await repo.approve(Ids.verifier, Ids.verUnverified);
    expect(approve.isOk, isTrue);
    // Reject another (needs a reason of 10+ characters).
    final reject = await repo.reject(
      Ids.superAdmin,
      Ids.verEngPending,
      'الصورة غير واضحة، برجاء رفع صورة أوضح',
    );
    expect(reject.isOk, isTrue);
    // Expire the internal booker's approval, then renew it.
    final current = (await decided(
      Ids.bookerInternal,
      VerificationStatus.approved,
    ));
    await repo.put(
      current.copyWith(expiresAt: env.now.subtract(const Duration(days: 1))),
    );
    expect(await repo.tierFor(Ids.bookerInternal, env.now), PriceTier.external);
    await repo.put(
      current.copyWith(expiresAt: env.now.add(const Duration(days: 300))),
    );
    expect(await repo.tierFor(Ids.bookerInternal, env.now), PriceTier.internal);
    // Expire it again so the last state differs from the seed.
    await repo.put(
      current.copyWith(expiresAt: env.now.subtract(const Duration(days: 1))),
    );

    expect(snapshot(), before);
  });

  test('a new booking takes the new tier and freezes it', () async {
    final bookings = env.layer.bookings;
    final repo = env.layer.verification;
    BookingRequest req(String user, int day) => BookingRequest(
      userId: user,
      unitId: Ids.futsal2,
      start: env.at(day, 18),
      end: env.at(day, 19),
      seats: 1,
    );

    // Karim is pending: external until approved.
    final first = (await bookings.create(
      req(Ids.userUnverified, 2),
    ) as Ok<Booking>).value;
    expect(first.tierAtBooking, PriceTier.external);

    await repo.approve(Ids.verifier, Ids.verUnverified);
    final second = (await bookings.create(
      req(Ids.userUnverified, 3),
    ) as Ok<Booking>).value;
    expect(second.tierAtBooking, PriceTier.internal);
    expect(second.priceAtBooking, lessThan(first.priceAtBooking));

    // Expiry later changes nothing already stored.
    final v = (await repo.current(Ids.userUnverified))!;
    await repo.put(
      v.copyWith(expiresAt: env.now.subtract(const Duration(days: 1))),
    );
    final a = (await bookings.get(first.id) as Ok<Booking>).value;
    final b = (await bookings.get(second.id) as Ok<Booking>).value;
    expect(
      (a.tierAtBooking, a.priceAtBooking),
      (first.tierAtBooking, first.priceAtBooking),
    );
    expect(
      (b.tierAtBooking, b.priceAtBooking),
      (second.tierAtBooking, second.priceAtBooking),
    );
    final third = (await bookings.create(
      req(Ids.userUnverified, 4),
    ) as Ok<Booking>).value;
    expect(third.tierAtBooking, PriceTier.external);
  });
}
