import 'package:flutter/material.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';

enum StatTrend { up, down, flat }

/// A comparison against an earlier period: "12%" with "عن الأسبوع اللي فات".
/// Good or bad is derived from [trend] and [higherIsBetter] (data-model.md).
class StatDelta {
  const StatDelta({
    required this.trend,
    required this.text,
    required this.comparison,
    this.higherIsBetter = true,
  });

  final StatTrend trend;
  final String text;
  final String comparison;
  final bool higherIsBetter;

  bool get isGood => switch (trend) {
        StatTrend.up => higherIsBetter,
        StatTrend.down => !higherIsBetter,
        StatTrend.flat => false,
      };

  /// `success` for good, `danger` for bad, `ink-muted` for flat.
  Color colorIn(SprintColors colors) => switch (trend) {
        StatTrend.flat => colors.inkMuted,
        _ => isGood ? colors.success : colors.danger,
      };
}
