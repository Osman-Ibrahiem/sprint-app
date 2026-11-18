import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';

import '../../../helpers/domain_builders.dart';

void main() {
  const full = {
    'day': '2026-11-19',
    'unit': 'u-pool-2',
    'trainer': 'tr-1',
    'start': '1700',
    'end': '1900',
  };

  test('reads every parameter', () {
    final s = ScheduleSelection.fromQuery(full);
    expect(s.day, DateTime(2026, 11, 19));
    expect(s.unitId, 'u-pool-2');
    expect(s.trainerId, 'tr-1');
    expect((s.startMinutes, s.endMinutes), (17 * 60, 19 * 60));
    expect(s.hasTime, isTrue);
    expect(s.isComplete, isTrue);
    expect(s.lengthMinutes, 120);
  });

  test('round-trips through the query in a fixed key order', () {
    final q = ScheduleSelection.fromQuery(full).toQuery();
    expect(q, full);
    expect(q.keys.toList(), ['day', 'unit', 'trainer', 'start', 'end']);
    expect(ScheduleSelection.fromQuery(q), ScheduleSelection.fromQuery(full));
  });

  test('writes only what is set', () {
    expect(ScheduleSelection.empty.toQuery(), isEmpty);
    expect(
      ScheduleSelection(day: DateTime(2026, 1, 5)).toQuery(),
      {'day': '2026-01-05'},
    );
  });

  test('drops what it cannot parse', () {
    final s = ScheduleSelection.fromQuery(const {
      'day': '19-11-2026',
      'unit': '',
      'start': '5pm',
      'end': '1900',
    });
    expect(s, ScheduleSelection.empty);
    expect(ScheduleSelection.fromQuery(const {'day': '2026-02-31'}).day, isNull);
    expect(
      ScheduleSelection.fromQuery(const {'start': '2500', 'end': '2600'}).hasTime,
      isFalse,
    );
  });

  test('a start without an end, or an end not after the start, is dropped', () {
    expect(ScheduleSelection.fromQuery(const {'start': '1700'}).hasTime, isFalse);
    expect(
      ScheduleSelection.fromQuery(const {'start': '1700', 'end': '1700'}).hasTime,
      isFalse,
    );
    expect(
      ScheduleSelection.fromQuery(const {'start': '1700', 'end': '1600'}).hasTime,
      isFalse,
    );
  });

  test('midnight as an end is accepted', () {
    final s = ScheduleSelection.fromQuery(const {'start': '2300', 'end': '2400'});
    expect(s.endMinutes, 1440);
  });

  test('a new day keeps unit and trainer and clears the time (FR-019)', () {
    final s = ScheduleSelection.fromQuery(full).withDay(DateTime(2026, 11, 20, 13));
    expect(s.day, DateTime(2026, 11, 20));
    expect((s.unitId, s.trainerId, s.hasTime), ('u-pool-2', 'tr-1', false));
  });

  test('a new unit clears the time; a new trainer clears time and unit', () {
    final base = ScheduleSelection.fromQuery(full);
    final u = base.withUnit('u2');
    expect((u.unitId, u.hasTime, u.day), ('u2', false, base.day));
    final t = base.withTrainer('tr-2');
    expect((t.trainerId, t.unitId, t.hasTime, t.day), ('tr-2', null, false, base.day));
  });

  test('instants are Cairo wall-clock converted to UTC (NFR-03)', () {
    final s = ScheduleSelection.fromQuery(full);
    expect(s.startInstant, cairo(2026, 11, 19, 17));
    expect(s.endInstant, cairo(2026, 11, 19, 19));
    expect(s.startInstant!.isUtc, isTrue);
    expect(cairoMinutesOf(cairo(2026, 11, 19, 17, 30)), 17 * 60 + 30);
    expect(cairoDayOf(cairo(2026, 11, 19, 23, 30)), DateTime(2026, 11, 19));
  });
}
