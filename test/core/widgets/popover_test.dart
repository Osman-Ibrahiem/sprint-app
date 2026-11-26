import 'dart:ui' show CheckedState;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/theme/sprint_theme.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/popover/popover.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

import '../../helpers/no_truncation.dart';
import '../../helpers/pump_app.dart' show setWindow;

/// Decision K2 of refactor 000: every row has a radio (filled when selected,
/// an empty ring otherwise), the popover is 260 to 380 wide by its labels,
/// and it is anchored by its real width.
void main() {
  setUpAll(loadSprintFonts);

  const short = [
    PopoverOption(value: 'ar', label: 'العربية', selected: true),
    PopoverOption(value: 'en', label: 'English'),
  ];
  const long = [
    PopoverOption(
      value: 'long',
      label:
          'كلية التربية الرياضية للبنين والبنات بجامعة طنطا، '
          'المجمع الرياضي الجديد بجوار المدينة الجامعية',
      selected: true,
    ),
    PopoverOption(value: 'b', label: 'الإدارة المركزية'),
  ];

  /// Opens the popover from a trigger at [alignment] in a [width] window,
  /// [inset] in from both side edges.
  Future<void> open(
    WidgetTester tester, {
    List<PopoverOption<String>> options = short,
    Locale locale = const Locale('ar'),
    double textScale = 1,
    bool dark = false,
    double width = 1000,
    AlignmentDirectional alignment = AlignmentDirectional.center,
    double inset = 0,
  }) async {
    setWindow(tester, size: Size(width, 800), textScale: textScale);
    final trigger = Builder(
      builder: (context) => TextButton(
        onPressed: () =>
            showSprintPopover<String>(anchorContext: context, options: options),
        child: const Text('open'),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? SprintTheme.dark : SprintTheme.light,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: inset),
            child: Align(alignment: alignment, child: trigger),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  BorderSide ring(WidgetTester tester, int i) {
    final circle = tester.widget<Container>(
      find.descendant(
        of: find.byKey(SprintPopover.radioKey(i)),
        matching: find.byType(Container),
      ),
    );
    return ((circle.decoration! as BoxDecoration).border! as Border).top;
  }

  for (final dark in [false, true]) {
    final colors = dark ? SprintColors.dark : SprintColors.light;
    testWidgets('radio: 22, selected a 6 primary ring, the others a 2 '
        'control-border ring (${dark ? 'dark' : 'light'})', (tester) async {
      await open(tester, dark: dark);
      for (var i = 0; i < 2; i++) {
        expect(
          tester.getSize(find.byKey(SprintPopover.radioKey(i))),
          const Size.square(SprintExtras.popoverRadioSize),
        );
      }
      expect(ring(tester, 0).color, colors.primary);
      expect(ring(tester, 0).width, SprintExtras.popoverRadioSelectedRing);
      expect(ring(tester, 1).color, colors.controlBorder);
      expect(ring(tester, 1).width, SprintExtras.popoverRadioRing);
    });
  }

  testWidgets('every row is 48 high at least and a radio button in semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await open(tester);
    for (var i = 0; i < short.length; i++) {
      expect(
        tester.getSize(find.byKey(SprintPopover.rowKey(i))).height,
        greaterThanOrEqualTo(SprintSize.controlHeight),
      );
    }
    final ar = tester.getSemantics(find.bySemanticsLabel('العربية'));
    expect(ar.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
    expect(ar.flagsCollection.isChecked, CheckedState.isTrue);
    final en = tester.getSemantics(find.bySemanticsLabel('English'));
    expect(en.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
    expect(en.flagsCollection.isChecked, CheckedState.isFalse);
    handle.dispose();
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets('width: short labels keep 260, a long label grows to the 380 '
        'cap and wraps, never cut (x$scale)', (tester) async {
      await open(tester, textScale: scale);
      final shortWidth = tester
          .getSize(find.byKey(SprintPopover.panelKey))
          .width;
      if (scale == 1.0) {
        expect(shortWidth, SprintExtras.popoverMinWidth);
      } else {
        expect(shortWidth, greaterThanOrEqualTo(SprintExtras.popoverMinWidth));
        expect(shortWidth, lessThanOrEqualTo(SprintExtras.popoverMaxWidth));
      }
      expectNoTruncation(tester);
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      await open(tester, options: long, textScale: scale);
      expect(
        tester.getSize(find.byKey(SprintPopover.panelKey)).width,
        SprintExtras.popoverMaxWidth,
      );
      expectNoTruncation(tester);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a label between the bounds sets the width', (tester) async {
    await open(
      tester,
      options: const [
        PopoverOption(
          value: 'a',
          label: 'كلية التربية الرياضية للبنين بجامعة طنطا',
        ),
      ],
    );
    final w = tester.getSize(find.byKey(SprintPopover.panelKey)).width;
    expect(w, greaterThan(SprintExtras.popoverMinWidth));
    expect(w, lessThan(SprintExtras.popoverMaxWidth));
  });

  for (final locale in const [Locale('ar'), Locale('en')]) {
    final rtl = locale.languageCode == 'ar';
    testWidgets('layout (${locale.languageCode}): label at the start, radio '
        'flush at the end, space-4 sides, space-2 top, space-1 between rows', (
      tester,
    ) async {
      await open(tester, locale: locale);
      final panel = tester.getRect(find.byKey(SprintPopover.panelKey));
      final radio = tester.getRect(find.byKey(SprintPopover.radioKey(1)));
      final label = tester.getRect(find.text('English'));
      // The 1px border is inside the panel, so insets are measured from it.
      const border = 1.0;
      if (rtl) {
        expect(radio.left, panel.left + border + SprintSpacing.space4);
        expect(
          label.right,
          lessThanOrEqualTo(panel.right - SprintSpacing.space4),
        );
        expect(radio.center.dx, lessThan(label.center.dx));
      } else {
        expect(radio.right, panel.right - border - SprintSpacing.space4);
        expect(radio.center.dx, greaterThan(label.center.dx));
      }
      final row0 = tester.getRect(find.byKey(SprintPopover.rowKey(0)));
      final row1 = tester.getRect(find.byKey(SprintPopover.rowKey(1)));
      expect(row0.top, panel.top + border + SprintSpacing.space2);
      expect(row1.top - row0.bottom, SprintSpacing.space1);
      // Radio centred on its row.
      expect(radio.center.dy, closeTo(row1.center.dy, 0.01));
    });
  }

  testWidgets('a wrapped label makes a 72 row, the radio centred, at least '
      'space-3 from the label', (tester) async {
    await open(tester, options: long);
    final row = tester.getRect(find.byKey(SprintPopover.rowKey(0)));
    final radio = tester.getRect(find.byKey(SprintPopover.radioKey(0)));
    final label = tester.getRect(find.text(long.first.label));
    expect(row.height, 72);
    expect(radio.center.dy, closeTo(row.center.dy, 0.01));
    expect(
      label.left - radio.right,
      greaterThanOrEqualTo(SprintSpacing.space3),
    );
  });

  for (final locale in const [Locale('ar'), Locale('en')]) {
    final rtl = locale.languageCode == 'ar';
    testWidgets('anchor: starts at the trigger\'s start edge and stays inside '
        'the window at both edges (${locale.languageCode})', (tester) async {
      for (final edge in [
        AlignmentDirectional.centerStart,
        AlignmentDirectional.centerEnd,
      ]) {
        // 40 in from each edge: room to line up at the start; at the end the
        // popover is wider than what is left and is pushed back inside.
        await open(
          tester,
          locale: locale,
          alignment: edge,
          width: 700,
          inset: 40,
        );
        final panel = tester.getRect(find.byKey(SprintPopover.panelKey));
        final trigger = tester.getRect(find.byType(TextButton));
        expect(panel.top, trigger.bottom + SprintSpacing.space1);
        expect(panel.left, greaterThanOrEqualTo(SprintSpacing.space2));
        expect(panel.right, lessThanOrEqualTo(700 - SprintSpacing.space2));
        final atStart = edge == AlignmentDirectional.centerStart;
        if (atStart) {
          // Room to line up with the trigger's start edge.
          if (rtl) {
            expect(panel.right, closeTo(trigger.right, 0.01));
          } else {
            expect(panel.left, closeTo(trigger.left, 0.01));
          }
        } else {
          // At the far edge the popover is pushed back inside the window.
          if (rtl) {
            expect(panel.left, SprintSpacing.space2);
          } else {
            expect(panel.right, 700 - SprintSpacing.space2);
          }
        }
        await tester.tapAt(const Offset(350, 700));
        await tester.pumpAndSettle();
      }
    });
  }
}
