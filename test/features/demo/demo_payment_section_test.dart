import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/theme/sprint_theme.dart';
import 'package:sprint/features/demo/presentation/demo_payment_section.dart';
import 'package:sprint/features/demo/presentation/demo_screen.dart';
import 'package:sprint/features/payments/data/fake_gateway_controller.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

import '../../helpers/pump_app.dart';

/// "الدفع التجريبي" on /demo (US-7, FR-010, SC-002).
void main() {
  Future<void> openDemo(WidgetTester tester) async {
    await pumpSprintApp(tester, size: const Size(500, 2400));
    routerOf(tester).push('/demo');
    await tester.pumpAndSettle();
  }

  FakeGatewayController gateway(WidgetTester tester) =>
      containerOf(tester).read(fakeGatewayProvider);

  testWidgets('the section shows with the demo tools, on success by default',
      (tester) async {
    await openDemo(tester);
    expect(find.byKey(DemoPaymentSection.keyOf), findsOneWidget);
    expect(find.text(ar.demoPaymentTitle), findsWidgets);
    expect(gateway(tester).outcome, const FakeOutcome.succeed());
    expect(find.text(ar.demoPaymentCurrent(ar.demoPaymentSuccess)),
        findsOneWidget);
  });

  testWidgets('hidden when the demo tools are hidden (HIDE_DEMO_TOOLS)',
      (tester) async {
    setWindow(tester, size: const Size(500, 2400));
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: SprintTheme.light,
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const DemoScreen(showToolLinks: false),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(DemoPaymentSection.keyOf), findsNothing);
  });

  testWidgets('choosing failure, delay and its presets sets the outcome',
      (tester) async {
    await openDemo(tester);
    await tester.tap(find.text(ar.demoPaymentFail));
    await tester.pumpAndSettle();
    expect(gateway(tester).outcome, const FakeOutcome.fail());

    await tester.tap(find.text(ar.demoPaymentDelay));
    await tester.pumpAndSettle();
    expect(gateway(tester).outcome, const FakeOutcome.delay(Duration(seconds: 30)));

    for (final s in [5, 90, 30]) {
      await tester.tap(find.text(ar.demoPaymentDelayPreset(s)));
      await tester.pumpAndSettle();
      expect(gateway(tester).outcome, FakeOutcome.delay(Duration(seconds: s)));
    }
    expect(find.text(ar.demoPaymentCurrent(ar.demoPaymentDelayCurrent(30))),
        findsOneWidget);
  });

  testWidgets('"after the maximum" is holdMaxMinutes + 1 minute, from the '
      'settings', (tester) async {
    await openDemo(tester);
    await containerOf(tester).read(settingsRepositoryProvider).set(
          SettingKeys.holdMaxMinutes,
          7,
          const SettingScope.university(),
          actorId: 'admin',
        );
    await tester.pumpAndSettle();
    // The section reads the setting when it opens: reopen it.
    routerOf(tester).pop();
    await tester.pumpAndSettle();
    routerOf(tester).push('/demo');
    await tester.pumpAndSettle();

    await tester.tap(find.text(ar.demoPaymentDelay));
    await tester.pumpAndSettle();
    await tester.tap(find.text(ar.demoPaymentDelayAfterMax));
    await tester.pumpAndSettle();
    expect(gateway(tester).outcome,
        const FakeOutcome.delay(Duration(minutes: 8)));
  });

  test('the choice is in the snapshot and a reset returns to success', () {
    final layer = InMemoryDataLayer.create(
      clock: Clock(() => DateTime.utc(2026, 11, 14, 6)),
      paymentDelay: Duration.zero,
    );
    layer.paymentProvider.gateway.outcome =
        const FakeOutcome.delay(Duration(seconds: 90));
    final back = InMemoryDataLayer.fromSnapshot(
      clock: Clock(() => DateTime.utc(2026, 11, 14, 6)),
      snapshot: layer.toSnapshot(),
      paymentDelay: Duration.zero,
    );
    expect(back.paymentProvider.gateway.outcome,
        const FakeOutcome.delay(Duration(seconds: 90)));
    final fresh = InMemoryDataLayer.fromSnapshot(
      clock: Clock(() => DateTime.utc(2026, 11, 14, 6)),
      paymentDelay: Duration.zero,
    );
    expect(fresh.paymentProvider.gateway.outcome, const FakeOutcome.succeed());
  });
}
