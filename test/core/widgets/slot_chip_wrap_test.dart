import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/theme/sprint_theme.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/widgets/slot_chip/slot_chip.dart';
import 'package:sprint/core/widgets/slot_chip/slot_state.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// A pressable control shrink-wraps its content: chips in a `Wrap` share rows
/// instead of each taking the whole width.
void main() {
  testWidgets('three chips in a 500 wide Wrap sit on one row', (tester) async {
    CairoTime.ensureInitialized();
    final start = CairoTime.atWallClock(2026, 11, 15, 9);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: SprintTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 500,
            child: Wrap(
              spacing: 8,
              children: [
                for (var i = 0; i < 3; i++)
                  SlotChip(
                    key: ValueKey('c$i'),
                    start: start.add(Duration(hours: i)),
                    state: SlotState.available,
                    fewLeftThreshold: 2,
                    onSelected: () {},
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    final tops = {
      for (var i = 0; i < 3; i++)
        tester.getTopLeft(find.byKey(ValueKey('c$i'))).dy,
    };
    expect(tops, hasLength(1), reason: 'one row');
    for (var i = 0; i < 3; i++) {
      expect(tester.getSize(find.byKey(ValueKey('c$i'))).width, lessThan(200));
    }
  });
}
