import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/theme/sprint_theme.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facilities_screen.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facility_not_found.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

import '../../../helpers/pump_app.dart';

final _now = CairoTime.atWallClock(2026, 11, 14, 8);

Future<void> pumpScreen(
  WidgetTester tester, {
  String? selectedId,
  Size size = const Size(400, 800),
}) async {
  setWindow(tester, size: size);
  final layer = InMemoryDataLayer.create(
    clock: Clock(() => _now),
    paymentDelay: Duration.zero,
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dataLayerProvider.overrideWithValue(layer),
        appClockProvider.overrideWithValue(Clock(() => _now)),
      ],
      child: MaterialApp(
        theme: SprintTheme.light,
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(body: FacilitiesScreen(selectedId: selectedId)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('compact', () {
    testWidgets('no id shows the list alone', (tester) async {
      await pumpScreen(tester);
      expect(find.byKey(FacilitiesScreen.listSlotKey), findsOneWidget);
      expect(find.byKey(FacilitiesScreen.detailsSlotKey), findsNothing);
    });

    testWidgets('an id shows the details alone', (tester) async {
      await pumpScreen(tester, selectedId: SeedIds.poolFacility);
      expect(find.byKey(FacilitiesScreen.detailsSlotKey), findsOneWidget);
      expect(find.byKey(FacilitiesScreen.listSlotKey), findsNothing);
      expect(find.text('حمام السباحة الأولمبي'), findsWidgets);
    });

    testWidgets('a missing id shows the not-found screen', (tester) async {
      await pumpScreen(tester, selectedId: 'nope');
      expect(find.byType(FacilityNotFound), findsOneWidget);
    });
  });

  group('medium and larger', () {
    testWidgets('700 shows list and the pane prompt', (tester) async {
      await pumpScreen(tester, size: const Size(700, 900));
      expect(find.byKey(FacilitiesScreen.listSlotKey), findsOneWidget);
      expect(find.byKey(FacilitiesScreen.detailsSlotKey), findsOneWidget);
      expect(find.text('اختار منشأة تشوف تفاصيلها'), findsOneWidget);
    });

    testWidgets('1000 shows list and the pane prompt', (tester) async {
      await pumpScreen(tester, size: const Size(1000, 900));
      expect(find.byKey(FacilitiesScreen.listSlotKey), findsOneWidget);
      expect(find.byKey(FacilitiesScreen.detailsSlotKey), findsOneWidget);
      expect(find.text('اختار منشأة تشوف تفاصيلها'), findsOneWidget);
    });

    testWidgets('the same id shows beside the list at 700 and 1000',
        (tester) async {
      for (final width in [700.0, 1000.0]) {
        await pumpScreen(
          tester,
          selectedId: SeedIds.poolFacility,
          size: Size(width, 900),
        );
        expect(find.byKey(FacilitiesScreen.listSlotKey), findsOneWidget);
        expect(find.byKey(FacilitiesScreen.detailsSlotKey), findsOneWidget);
        expect(find.text('حمام السباحة الأولمبي'), findsWidgets);
      }
    });

    testWidgets('a missing id shows the not-found screen in the pane',
        (tester) async {
      await pumpScreen(tester, selectedId: 'nope', size: const Size(1000, 900));
      expect(find.byKey(FacilitiesScreen.listSlotKey), findsOneWidget);
      expect(find.byType(FacilityNotFound), findsOneWidget);
    });
  });
}
