import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/catalogue/domain/bookable_unit.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/catalogue/domain/price_groups.dart';
import 'package:sprint/features/settings/domain/booking_mode.dart';

BookableUnit unit(String id, {bool active = true}) =>
    BookableUnit(id: id, facilityId: 'f', name: 'وحدة $id', isActive: active);

Price p(String id, PriceTier t, int a) => Price(unitId: id, tier: t, amount: a);

void main() {
  BookingMode shared(String _) => BookingMode.shared;

  test('six equal lanes become one group covering all units', () {
    final units = [for (var i = 1; i <= 6; i++) unit('l$i')];
    final prices = [
      for (final u in units) ...[
        p(u.id, PriceTier.internal, 20),
        p(u.id, PriceTier.external, 40),
      ],
    ];
    final groups =
        PriceGroups.build(units: units, prices: prices, modeOf: shared);
    expect(groups, hasLength(1));
    expect(groups.single.coversAllUnits, isTrue);
    expect(groups.single.unitIds, hasLength(6));
    expect(groups.single.internal, 20);
    expect(groups.single.external, 40);
  });

  test('two different pitches become two groups', () {
    final units = [unit('a'), unit('b')];
    final prices = [
      p('a', PriceTier.internal, 100),
      p('a', PriceTier.external, 200),
      p('b', PriceTier.internal, 150),
      p('b', PriceTier.external, 300),
    ];
    final groups = PriceGroups.build(
        units: units, prices: prices, modeOf: (_) => BookingMode.exclusive);
    expect(groups, hasLength(2));
    expect(groups.every((g) => !g.coversAllUnits), isTrue);
  });

  test('mixed modes split groups even at the same price', () {
    final units = [unit('a'), unit('b')];
    final prices = [
      for (final id in ['a', 'b']) ...[
        p(id, PriceTier.internal, 50),
        p(id, PriceTier.external, 90),
      ],
    ];
    final groups = PriceGroups.build(
      units: units,
      prices: prices,
      modeOf: (id) => id == 'a' ? BookingMode.exclusive : BookingMode.shared,
    );
    expect(groups, hasLength(2));
  });

  test('a missing price is null, never 0', () {
    final groups = PriceGroups.build(
      units: [unit('a')],
      prices: [p('a', PriceTier.internal, 30)],
      modeOf: shared,
    );
    expect(groups.single.internal, 30);
    expect(groups.single.external, isNull);
  });

  test('inactive units never appear', () {
    final groups = PriceGroups.build(
      units: [unit('a'), unit('b', active: false)],
      prices: [p('a', PriceTier.internal, 30), p('b', PriceTier.internal, 99)],
      modeOf: shared,
    );
    expect(groups.single.unitIds, ['a']);
    expect(groups.single.coversAllUnits, isTrue);
  });
}
