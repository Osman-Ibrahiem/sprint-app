import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';

/// WCAG contrast over the token pairs the design system promises in
/// `tokens.json` usages (refactor 000, decisions C1 and C2): text 4.5:1,
/// controls and focus 3:1, in both themes. A future token value that drops a
/// pair below its floor fails here.
void main() {
  double channel(double c) =>
      c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

  double luminance(Color c) =>
      0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);

  double ratio(Color a, Color b) {
    final la = luminance(a);
    final lb = luminance(b);
    final hi = math.max(la, lb);
    final lo = math.min(la, lb);
    return (hi + 0.05) / (lo + 0.05);
  }

  const text = 4.5;
  const control = 3.0;

  /// (name, foreground, background, floor) for one theme.
  List<(String, Color, Color, double)> pairs(SprintColors c) => [
    // Text and icons on every ground.
    for (final (g, ground) in [
      ('bg', c.bg),
      ('surface', c.surface),
      ('surface-raised', c.surfaceRaised),
      ('surface-sunken', c.surfaceSunken),
    ]) ...[
      ('ink on $g', c.ink, ground, text),
      ('ink-muted on $g', c.inkMuted, ground, text),
      // C1: a bordered control may sit on any ground.
      ('control-border on $g', c.controlBorder, ground, control),
    ],
    ('primary on surface', c.primary, c.surface, text),
    ('primary on bg', c.primary, c.bg, text),
    ('primary on surface-raised', c.primary, c.surfaceRaised, text),
    // Fills and their labels, every state (U1 hover and pressed).
    ('on-primary on primary', c.onPrimary, c.primary, text),
    ('on-primary on primary-hover', c.onPrimary, c.primaryHover, text),
    ('on-primary on primary-pressed', c.onPrimary, c.primaryPressed, text),
    ('on-primary-soft on primary-soft', c.onPrimarySoft, c.primarySoft, text),
    (
      'on-primary-soft on primary-soft-hover',
      c.onPrimarySoft,
      c.primarySoftHover,
      text,
    ),
    (
      'on-primary-soft on primary-soft-pressed',
      c.onPrimarySoft,
      c.primarySoftPressed,
      text,
    ),
    ('on-danger on danger', c.onDanger, c.danger, text),
    ('on-danger on danger-hover', c.onDanger, c.dangerHover, text),
    ('on-danger on danger-pressed', c.onDanger, c.dangerPressed, text),
    ('on-volt on volt', c.onVolt, c.volt, text),
    // Status colours as text on their soft grounds and on surface (C2).
    ('success on surface', c.success, c.surface, text),
    ('success on success-soft', c.success, c.successSoft, text),
    ('warning on surface', c.warning, c.surface, text),
    ('warning on warning-soft', c.warning, c.warningSoft, text),
    ('danger on surface', c.danger, c.surface, text),
    ('danger on danger-soft', c.danger, c.dangerSoft, text),
    // Focus ring and the selected fill are controls.
    ('focus-ring on bg', c.focusRing, c.bg, control),
    ('focus-ring on surface', c.focusRing, c.surface, control),
    ('focus-ring on surface-raised', c.focusRing, c.surfaceRaised, control),
    ('primary fill on surface', c.primary, c.surface, control),
    // Scanners need dark modules on a light ground in both themes.
    ('qr-ink on qr-ground', c.qrInk, c.qrGround, text),
  ];

  for (final (theme, colors) in [
    ('light', SprintColors.light),
    ('dark', SprintColors.dark),
  ]) {
    test('every token pair reaches its contrast floor: $theme', () {
      final failures = <String>[];
      for (final (name, fg, bg, floor) in pairs(colors)) {
        final r = ratio(fg, bg);
        if (r < floor) {
          failures.add('$name ${r.toStringAsFixed(2)} < $floor');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });
  }

  test('the measured values of decisions C1 and C2', () {
    final l = SprintColors.light;
    final d = SprintColors.dark;
    expect(ratio(l.controlBorder, l.bg), closeTo(3.27, 0.01));
    expect(ratio(l.controlBorder, l.surface), closeTo(3.51, 0.01));
    expect(ratio(l.controlBorder, l.surfaceSunken), closeTo(3.08, 0.01));
    expect(ratio(d.controlBorder, d.surfaceRaised), closeTo(3.16, 0.01));
    expect(ratio(l.success, l.successSoft), closeTo(4.72, 0.01));
    expect(ratio(l.success, l.surface), closeTo(5.28, 0.01));
  });

  test('hover and pressed fills differ from their resting fill (U1)', () {
    for (final c in [SprintColors.light, SprintColors.dark]) {
      expect(c.primarySoftHover, isNot(c.primarySoft));
      expect(c.primarySoftPressed, isNot(c.primarySoftHover));
      expect(c.dangerHover, isNot(c.danger));
      expect(c.dangerPressed, isNot(c.dangerHover));
    }
  });
}
