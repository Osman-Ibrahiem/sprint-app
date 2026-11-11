import 'package:clock/clock.dart';
import 'package:sprint/core/data/in_memory_data_layer.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/time/cairo_time.dart';

/// A data layer over the seed with a clock the test can move.
class DataEnv {
  DataEnv._(this._now) {
    layer = InMemoryDataLayer.create(
      clock: Clock(() => _now),
      paymentDelay: Duration.zero,
    );
  }

  /// 2026-11-14 08:00 in Cairo, a Saturday.
  factory DataEnv([DateTime? now]) {
    CairoTime.ensureInitialized();
    return DataEnv._(now ?? CairoTime.atWallClock(2026, 11, 14, 8));
  }

  DateTime _now;
  late final InMemoryDataLayer layer;

  DateTime get now => _now;
  void advance(Duration d) => _now = _now.add(d);
  void setNow(DateTime t) => _now = t;

  /// Cairo wall-clock `daysFromToday` days from today at [hour]:[minute].
  DateTime at(int daysFromToday, int hour, [int minute = 0]) {
    final c = CairoTime.toCairo(_now);
    return CairoTime.atWallClock(c.year, c.month, c.day + daysFromToday, hour, minute);
  }
}

typedef Ids = SeedIds;
