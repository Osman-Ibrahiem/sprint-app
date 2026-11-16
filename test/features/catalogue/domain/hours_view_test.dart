import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/features/catalogue/domain/closure.dart';
import 'package:sprint/features/catalogue/domain/hours_view.dart';
import 'package:sprint/features/catalogue/domain/operating_hours.dart';

List<OperatingHours> week(String owner, int open, int close,
        {List<int> skip = const []}) =>
    [
      for (var d = 1; d <= 7; d++)
        if (!skip.contains(d))
          OperatingHours(
              ownerId: owner, dayOfWeek: d, openMinutes: open, closeMinutes: close),
    ];

// 2026-11-14 is a Saturday.
DateTime at(int day, int h, [int m = 0]) => CairoTime.atWallClock(2026, 11, day, h, m);

HoursView build({
  List<OperatingHours>? facility,
  Map<String, List<OperatingHours>> units = const {},
  List<Closure> closures = const [],
  required DateTime now,
  List<String> allUnitIds = const [],
}) =>
    HoursView.build(
      facilityHours: facility ?? week('f', 8 * 60, 22 * 60),
      unitHours: units,
      closures: closures,
      now: now,
      allUnitIds: allUnitIds,
    );

void main() {
  test('a closed day has null times', () {
    final v = build(
        facility: week('f', 480, 1320, skip: [DateTime.friday]), now: at(14, 12));
    final friday = v.days.firstWhere((d) => d.dayOfWeek == DateTime.friday);
    expect(friday.isClosed, isTrue);
    expect(friday.openMinutes, isNull);
    expect(v.todayDayOfWeek, DateTime.saturday);
  });

  test('a unit with different hours is an override', () {
    final v = build(
      units: {'l6': week('l6', 16 * 60, 22 * 60)},
      now: at(14, 12),
    );
    expect(v.unitOverrides.keys, ['l6']);
  });

  test('equal unit hours produce no override', () {
    final v = build(units: {'l1': week('l1', 8 * 60, 22 * 60)}, now: at(14, 12));
    expect(v.unitOverrides, isEmpty);
  });

  test('a facility closure now closes it; an upcoming one does not', () {
    Closure c(int from, int to) => Closure(
          id: 'c',
          scope: ClosureScope.facility,
          scopeId: 'f',
          from: at(from, 0),
          to: at(to, 0),
          reason: 'صيانة',
        );
    expect(build(closures: [c(14, 15)], now: at(14, 12)).closedNow, isTrue);
    expect(build(closures: [c(18, 19)], now: at(14, 12)).closedNow, isFalse);
  });

  test('closures on every unit count, on one unit do not', () {
    Closure u(String id) => Closure(
          id: id,
          scope: ClosureScope.unit,
          scopeId: id,
          from: at(14, 0),
          to: at(15, 0),
          reason: 'x',
        );
    expect(
        build(closures: [u('a')], allUnitIds: ['a', 'b'], now: at(14, 12))
            .closedNow,
        isFalse);
    expect(
        build(closures: [u('a'), u('b')], allUnitIds: ['a', 'b'], now: at(14, 12))
            .closedNow,
        isTrue);
  });

  test('closed just before opening and just after closing, in Cairo time', () {
    expect(build(now: at(14, 7, 59)).closedNow, isTrue);
    expect(build(now: at(14, 8)).closedNow, isFalse);
    expect(build(now: at(14, 21, 59)).closedNow, isFalse);
    expect(build(now: at(14, 22)).closedNow, isTrue);
  });
}
