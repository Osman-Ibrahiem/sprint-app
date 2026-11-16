import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/facility_summary.dart';
import 'package:sprint/features/catalogue/presentation/details/availability_section.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facility_filter_bar.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facility_list_view.dart';
import 'package:sprint/features/catalogue/presentation/providers/catalogue_providers.dart';

import '../../../helpers/pump_app.dart';

bool focusIn(Key key) {
  var found = false;
  FocusManager.instance.primaryFocus?.context?.visitAncestorElements((e) {
    if (e.widget.key == key) {
      found = true;
      return false;
    }
    return true;
  });
  return found;
}

Future<bool> tabTo(WidgetTester tester, Key key, {int max = 60}) async {
  for (var i = 0; i < max; i++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    if (focusIn(key)) return true;
  }
  return false;
}

void main() {
  testWidgets('Tab reaches filters then cards; Enter and Space activate',
      (tester) async {
    await pumpSprintApp(tester, size: const Size(400, 3000));
    routerOf(tester).go('/facilities');
    await tester.pumpAndSettle();

    expect(await tabTo(tester, FacilityFilterBar.typeKey(FacilityType.tennis)), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(containerOf(tester).read(facilityFilterProvider).type, FacilityType.tennis);

    expect(await tabTo(tester, FacilityFilterBar.freeKey(true)), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(containerOf(tester).read(facilityFilterProvider).free, isTrue);
  });

  testWidgets('Tab reaches a card and Enter opens it', (tester) async {
    await pumpSprintApp(tester, size: const Size(400, 3000));
    routerOf(tester).go('/facilities');
    await tester.pumpAndSettle();
    expect(await tabTo(tester, FacilityListView.cardKey(SeedIds.poolFacility)),
        isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(currentPath(tester), '/facilities/${SeedIds.poolFacility}');
  });

  testWidgets('the details action is reachable by keyboard', (tester) async {
    await pumpSprintApp(tester, size: const Size(400, 3000));
    routerOf(tester).go('/facilities/${SeedIds.poolFacility}');
    await tester.pumpAndSettle();
    expect(await tabTo(tester, AvailabilitySection.actionKey), isTrue);
  });

  testWidgets('with reduced motion the loading list schedules no frames',
      (tester) async {
    final never = Completer<List<FacilitySummary>>();
    await pumpSprintApp(
      tester,
      size: const Size(400, 900),
      overrides: [
        facilitySummariesProvider.overrideWith((ref) => never.future),
      ],
    );
    routerOf(tester).go('/facilities');
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
