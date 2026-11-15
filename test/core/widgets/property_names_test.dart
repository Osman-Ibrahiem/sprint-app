import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/widgets/design_system.dart';

import 'widget_samples.dart';

/// FR-011: the public property names match the handoff.md component table, so a
/// rename fails here before it drifts from Figma.
void main() {
  final expected = <String, Map<String, Object? Function(dynamic)>>{
    'SprintButton': {
      'label': (w) => w.label,
      'variant': (w) => w.variant,
      'size': (w) => w.size,
      'icon': (w) => w.icon,
      'loading': (w) => w.loading,
      'onPressed': (w) => w.onPressed,
    },
    'SprintTextField': {
      'label': (w) => w.label,
      'type': (w) => w.type,
      'helper': (w) => w.helper,
      'error': (w) => w.error,
      'enabled': (w) => w.enabled,
    },
    'SlotChip': {
      'state': (w) => w.state,
      'price': (w) => w.price,
      'remaining': (w) => w.remaining,
      'onSelected': (w) => w.onSelected,
    },
    'DayStrip': {
      'days': (w) => w.days,
      'selected': (w) => w.selected,
      'onSelected': (w) => w.onSelected,
    },
    'StatusBadge': {'status': (w) => w.status},
    'SprintLogo': {'variant': (w) => w.variant, 'size': (w) => w.size},
    'FacilityCard': {
      'kind': (w) => w.kind,
      'layout': (w) => w.layout,
      'name': (w) => w.name,
      'tags': (w) => w.tags,
      'price': (w) => w.price,
      'onTap': (w) => w.onTap,
    },
    'BookingTicket': {
      'state': (w) => w.state,
      'status': (w) => w.status,
      'code': (w) => w.code,
      'qrToken': (w) => w.qrToken,
    },
    'AppNavigation': {
      'destinations': (w) => w.destinations,
      'selected': (w) => w.selected,
      'form': (w) => w.form,
    },
    'StatTile': {
      'label': (w) => w.label,
      'value': (w) => w.value,
      'unit': (w) => w.unit,
      'delta': (w) => w.delta,
      'onTap': (w) => w.onTap,
    },
  };

  final samples = plainWidgets();
  test('every widget is covered', () {
    expect(samples.keys.toSet(), expected.keys.toSet());
  });

  for (final entry in expected.entries) {
    test('${entry.key} exposes the handoff property names', () {
      final widget = samples[entry.key]!;
      for (final prop in entry.value.entries) {
        expect(
          () => prop.value(widget),
          returnsNormally,
          reason: '${entry.key}.${prop.key} is missing',
        );
      }
    });
  }

  test('trend lives on the stat delta', () {
    const d = StatDelta(trend: StatTrend.up, text: '1%', comparison: 'x');
    expect(d.trend, StatTrend.up);
  });
}
