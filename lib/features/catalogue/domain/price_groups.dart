import 'package:sprint/features/catalogue/domain/bookable_unit.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/settings/domain/booking_mode.dart';

/// Active units that share one booking mode and one price per tier. A null
/// amount means "no price set yet", never 0 (FR-017, FR-021, BR-15, BR-16).
class PriceGroup {
  const PriceGroup({
    required this.unitIds,
    required this.unitNames,
    required this.coversAllUnits,
    required this.mode,
    this.internal,
    this.external,
  });

  final List<String> unitIds;
  final List<String> unitNames;
  final bool coversAllUnits;
  final BookingMode mode;
  final int? internal;
  final int? external;
}

abstract final class PriceGroups {
  /// Groups active units by (mode, internal amount, external amount), in the
  /// order the first unit of each group appears. A free facility is decided by
  /// the screen, not here. Inactive units never appear.
  static List<PriceGroup> build({
    required List<BookableUnit> units,
    required List<Price> prices,
    required BookingMode Function(String unitId) modeOf,
  }) {
    final active = units.where((u) => u.isActive).toList();
    int? amount(String unitId, PriceTier tier) {
      for (final p in prices) {
        if (p.unitId == unitId && p.tier == tier) return p.amount;
      }
      return null;
    }

    final buckets = <(BookingMode, int?, int?), List<BookableUnit>>{};
    for (final unit in active) {
      final key = (
        modeOf(unit.id),
        amount(unit.id, PriceTier.internal),
        amount(unit.id, PriceTier.external),
      );
      buckets.putIfAbsent(key, () => []).add(unit);
    }

    return [
      for (final entry in buckets.entries)
        PriceGroup(
          unitIds: [for (final u in entry.value) u.id],
          unitNames: [for (final u in entry.value) u.name],
          coversAllUnits: entry.value.length == active.length,
          mode: entry.key.$1,
          internal: entry.key.$2,
          external: entry.key.$3,
        ),
    ];
  }
}
