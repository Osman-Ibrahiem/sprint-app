import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/catalogue/presentation/details/hours_section.dart';
import 'package:sprint/features/catalogue/presentation/details/price_section.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facility_filter_bar.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facility_list_view.dart';
import 'package:sprint/features/catalogue/presentation/home/home_screen.dart';
import 'package:sprint/features/catalogue/presentation/home/upcoming_bookings_section.dart';

import '../../../helpers/pump_app.dart';

String labelOf(WidgetTester tester, Finder f) =>
    tester.getSemantics(f.first).label;

void main() {
  testWidgets('cards, chips, booking rows, hours and prices speak Arabic',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pumpSprintApp(tester, size: const Size(400, 3000));
    await containerOf(tester)
        .read(sessionProvider.notifier)
        .selectUser(SeedIds.bookerInternal);
    await tester.pumpAndSettle();

    // Home: type chip, booking row.
    final typeChip = find.byKey(HomeScreen.typeChipKey(FacilityType.swimming));
    expect(labelOf(tester, typeChip), contains(ar.catalogueTypeSwimming));
    final row = find.byWidgetPredicate((w) =>
        w.key is ValueKey<String> &&
        (w.key! as ValueKey<String>).value.startsWith('upcoming-b'));
    expect(row, findsWidgets);
    expect(labelOf(tester, row), contains(ar.statusConfirmed));
    expect(find.byKey(UpcomingBookingsSection.seeAllKey), findsOneWidget);

    // List: card and filter chips.
    routerOf(tester).go('/facilities');
    await tester.pumpAndSettle();
    final card = find.byKey(FacilityListView.cardKey(SeedIds.poolFacility));
    final cardLabel = labelOf(tester, card);
    expect(cardLabel, contains('حمام السباحة الأولمبي'));
    expect(cardLabel, contains('كلية التربية الرياضية'));
    expect(cardLabel, contains('ج.م'));
    final chip = find.byKey(FacilityFilterBar.typeKey(FacilityType.gym));
    expect(labelOf(tester, chip), contains(ar.catalogueTypeGym));

    // Details: hours and price rows.
    routerOf(tester).go('/facilities/${SeedIds.poolFacility}');
    await tester.pumpAndSettle();
    final day = find.byKey(HoursSection.dayKey(1));
    expect(labelOf(tester, day), contains(ar.catalogueDayName('1')));
    final mine = find.byKey(PriceSection.rowKey(0, PriceTier.internal));
    expect(labelOf(tester, mine), contains(ar.cataloguePriceYours));
    expect(labelOf(tester, mine), contains('ج.م'));
    final other = find.byKey(PriceSection.rowKey(0, PriceTier.external));
    expect(labelOf(tester, other), isNot(contains(ar.cataloguePriceYours)));
    handle.dispose();
  });
}
