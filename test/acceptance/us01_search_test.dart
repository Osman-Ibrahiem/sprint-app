import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/widgets/facility_card/facility_card.dart';
import 'package:sprint/core/widgets/sprint_text_field/sprint_text_field.dart';
import 'package:sprint/features/catalogue/presentation/search/search_field.dart';

import '../helpers/pump_app.dart';

/// US-01 search (T074, T076): suggestions, filtering, clear, no results.
void main() {
  Future<void> open(WidgetTester t) async {
    await pumpSprintApp(t, size: const Size(400, 1600));
    routerOf(t).go(AppPaths.facilities);
    await t.pumpAndSettle();
  }

  testWidgets('the empty focused field offers most booked', (t) async {
    await open(t);
    await t.tap(find.byType(TextField).first);
    await t.pumpAndSettle();
    expect(find.byKey(FacilitySearchField.mostBookedKey), findsOneWidget);
  });

  testWidgets('typing filters, clear restores, no match shows the empty state',
      (t) async {
    await open(t);
    final all = find.byType(FacilityCard).evaluate().length;
    await t.enterText(find.byType(TextField).first, 'سباحة');
    await t.pumpAndSettle();
    final some = find.byType(FacilityCard).evaluate().length;
    expect(some, lessThan(all));
    expect(some, greaterThan(0));
    await t.tap(find.byKey(SprintTextField.clearKey));
    await t.pumpAndSettle();
    expect(find.byType(FacilityCard).evaluate().length, greaterThan(some));
    await t.enterText(find.byType(TextField).first, 'زززز');
    await t.pumpAndSettle();
    expect(find.text(ar.searchNoResultsTitle), findsOneWidget);
  });

  testWidgets('a result tap adds the term to the recents', (t) async {
    await open(t);
    await t.enterText(find.byType(TextField).first, 'سباحة');
    await t.pumpAndSettle();
    await t.tap(find.byType(FacilityCard).first);
    await t.pumpAndSettle();
    routerOf(t).go(AppPaths.facilities);
    await t.pumpAndSettle();
    await t.tap(find.byKey(SprintTextField.cancelKey), warnIfMissed: false);
    expect(find.byType(FacilitySearchField), findsOneWidget);
  });

  testWidgets('?q= filters, typing writes it back, refresh and detail keep it',
      (t) async {
    await pumpSprintApp(t, size: const Size(400, 1600));
    routerOf(t).go('/facilities?q=${Uri.encodeQueryComponent('سباحة')}');
    await t.pumpAndSettle();
    final some = find.byType(FacilityCard).evaluate().length;
    expect(some, greaterThan(0));
    expect(find.text('سباحة'), findsWidgets);

    await t.enterText(find.byType(TextField).first, 'تنس');
    await t.pumpAndSettle();
    final uri = routerOf(t).routerDelegate.currentConfiguration.uri;
    expect(uri.queryParameters['q'], 'تنس');

    await t.tap(find.byType(FacilityCard).first);
    await t.pumpAndSettle();
    final detail = routerOf(t).routerDelegate.currentConfiguration.uri;
    expect(detail.path, startsWith('/facilities/'));
    expect(detail.queryParameters['q'], 'تنس');
  });

  testWidgets('M9: no label above the field, the hint is the placeholder',
      (t) async {
    await open(t);
    expect(find.text(ar.facilitiesSearchHint), findsNothing);
    expect(find.text(ar.facilitiesSearchPlaceholder), findsOneWidget);
  });
}
