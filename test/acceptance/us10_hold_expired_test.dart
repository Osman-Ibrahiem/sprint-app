import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/features/booking/domain/booking.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/booking/presentation/checkout/checkout_screen.dart';
import 'package:sprint/features/booking/presentation/checkout/expired_view.dart';
import 'package:sprint/features/payments/presentation/fake_gateway_screen.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';

import '../features/booking/presentation/checkout/checkout_harness.dart';
import '../helpers/pump_app.dart';

/// US-10, BR-12: holdMinutes = 1; the booker enters payment and waits.
void main() {
  testWidgets('a one-minute Hold ends while on the provider page: expired, '
      'and the place is free for another account', (tester) async {
    final env = await CheckoutEnv.open(
      tester,
      arrange: (layer) async {
        await layer.settings.set(
          SettingKeys.holdMinutes,
          1,
          const SettingScope.university(),
          actorId: 'admin',
        );
      },
    );
    await tester.tap(find.byKey(CheckoutScreen.payKey));
    await tester.pumpAndSettle();
    expect(find.byType(FakeGatewayScreen), findsOneWidget);

    await env.advance(const Duration(minutes: 1, seconds: 5));
    await tester.pumpAndSettle();
    // The pending payment extends the Hold to its maximum (BR-46), so the
    // place is still held while the provider has not answered.
    expect((await env.reload()).status, BookingStatus.pendingPayment);

    // Past the maximum with nothing answered: released.
    await env.advance(const Duration(minutes: 20));
    await tester.pumpAndSettle();
    expect((await env.reload()).status, BookingStatus.expired);
    final other = await env.layer.bookings.quote(BookingRequest(
      userId: SeedIds.bookerExternal,
      unitId: env.booking.unitId,
      start: env.booking.start,
      end: env.booking.end,
    ));
    expect(other.isOk, isTrue);

    // Back from the page: the expired state.
    await tester.tap(find.byKey(const ValueKey<String>('gateway-cancel')));
    await tester.pumpAndSettle();
    expect(find.byKey(ExpiredView.titleKey), findsOneWidget);
    expect(find.text(ar.holdExpiredTitle), findsOneWidget);
  });
}
