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

  Iterable<BoxDecoration> circles(WidgetTester tester, int i) => tester
      .widgetList<Container>(
        find.descendant(
          of: find.byKey(SprintPopover.radioKey(i)),
          matching: find.byType(Container),
        ),
      )
      .map((c) => c.decoration! as BoxDecoration);

  BoxDecoration radio(WidgetTester tester, int i) => circles(tester, i).first;

  bool filled(WidgetTester tester, int i) => circles(tester, i).length > 1;

  for (final dark in [false, true]) {
    final colors = dark ? SprintColors.dark : SprintColors.light;
    testWidgets('radio: the selected row is filled primary, the others an '
        'empty control-border ring (${dark ? 'dark' : 'light'})', (
      tester,
    ) async {
      await open(tester, dark: dark);
      expect((radio(tester, 0).border! as Border).top.color, colors.primary);
      expect(filled(tester, 0), isTrue);
      expect(
        (radio(tester, 1).border! as Border).top.color,
        colors.controlBorder,
      );
      expect(filled(tester, 1), isFalse);
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

  testWidgets('RTL: the radio sits on the start side (right) of its label', (
    tester,
  ) async {
    await open(tester);
    expect(
      tester.getCenter(find.byKey(SprintPopover.radioKey(1))).dx,
      greaterThan(tester.getCenter(find.text('English')).dx),
    );
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();
    await open(tester, locale: const Locale('en'));
    expect(
      tester.getCenter(find.byKey(SprintPopover.radioKey(1))).dx,
      lessThan(tester.getCenter(find.text('English')).dx),
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
