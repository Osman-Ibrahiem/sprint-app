import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/l10n/directional_icon.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';

Widget _host(TextDirection d, Widget child) => Directionality(
      textDirection: d,
      child: Center(child: child),
    );

/// Phosphor glyphs match text direction, so a raw Icon flips in RTL; the
/// wrappers must not let that happen behind their back (FR-019).
bool _flipped(WidgetTester t, Finder inside) {
  final transforms = t.widgetList<Transform>(
    find.descendant(of: inside, matching: find.byType(Transform)),
  );
  // Icon itself flips with a Transform when matchTextDirection applies.
  return transforms.any((w) => w.transform.storage[0] < 0);
}

void main() {
  const glyph = PhosphorIconsRegular.check;

  for (final d in TextDirection.values) {
    testWidgets('SprintIcon never flips ($d)', (t) async {
      await t.pumpWidget(_host(d, const SprintIcon(glyph)));
      expect(_flipped(t, find.byType(SprintIcon)), isFalse);
    });
  }

  testWidgets('DirectionalIcon flips once in RTL', (t) async {
    await t.pumpWidget(_host(TextDirection.rtl, const DirectionalIcon(glyph)));
    final n = t
        .widgetList<Transform>(find.descendant(
          of: find.byType(DirectionalIcon),
          matching: find.byType(Transform),
        ))
        .where((w) => w.transform.storage[0] < 0)
        .length;
    expect(n, 1);
  });

  testWidgets('DirectionalIcon does not flip in LTR', (t) async {
    await t.pumpWidget(_host(TextDirection.ltr, const DirectionalIcon(glyph)));
    expect(_flipped(t, find.byType(DirectionalIcon)), isFalse);
  });

  testWidgets('DirectionalIcon(mirror: false) does not flip in RTL', (t) async {
    await t.pumpWidget(
      _host(TextDirection.rtl, const DirectionalIcon(glyph, mirror: false)),
    );
    expect(_flipped(t, find.byType(DirectionalIcon)), isFalse);
  });

  testWidgets('a raw Icon would flip in RTL (why the wrappers exist)',
      (t) async {
    await t.pumpWidget(_host(TextDirection.rtl, const Icon(glyph)));
    expect(_flipped(t, find.byType(Icon)), isTrue);
  });
}
