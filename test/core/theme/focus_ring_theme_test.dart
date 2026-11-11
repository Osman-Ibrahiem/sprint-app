import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/theme/sprint_theme.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';

import '../../helpers/pump_app.dart';

/// FR-017: every interactive control shows the focus ring on keyboard focus.
void main() {
  final themes = {
    'light': (SprintTheme.light, SprintColors.light),
    'dark': (SprintTheme.dark, SprintColors.dark),
  };

  themes.forEach((name, pair) {
    final (theme, colors) = pair;

    group('$name theme', () {
      const focused = {WidgetState.focused};

      BorderSide? side(ButtonStyle? s, Set<WidgetState> states) =>
          s?.side?.resolve(states);

      test('filled, outlined and text buttons draw the focus-ring when focused',
          () {
        for (final style in [
          theme.filledButtonTheme.style,
          theme.outlinedButtonTheme.style,
          theme.textButtonTheme.style,
        ]) {
          final s = side(style, focused);
          expect(s?.color, colors.focusRing);
          expect(s?.width, SprintExtras.focusRingWidth);
        }
      });

      test('the outlined button keeps its control border at rest', () {
        expect(side(theme.outlinedButtonTheme.style, {})?.color,
            colors.controlBorder);
      });

      test('text fields and switches show the ring on focus', () {
        final border = theme.inputDecorationTheme.focusedBorder!
            as OutlineInputBorder;
        expect(border.borderSide.color, colors.focusRing);
        expect(border.borderSide.width, SprintExtras.focusRingWidth);

        expect(theme.switchTheme.trackOutlineColor!.resolve(focused),
            colors.focusRing);
        expect(theme.switchTheme.trackOutlineWidth!.resolve(focused),
            SprintExtras.focusRingWidth);
        expect(theme.switchTheme.trackOutlineWidth!.resolve({}), 0);
      });
    });
  });

  testWidgets('the Facilities search field shows the ring when focused',
      (tester) async {
    await pumpSprintApp(tester, size: const Size(400, 800));
    routerOf(tester).go('/facilities');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    final field = tester.widget<TextField>(find.byType(TextField));
    final border = field.decoration!.focusedBorder! as OutlineInputBorder;
    expect(border.borderSide.width, SprintExtras.focusRingWidth);
  });
}
