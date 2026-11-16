import 'package:sprint/features/catalogue/domain/closure.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/hours_view.dart';
import 'package:sprint/features/catalogue/domain/price_groups.dart';
import 'package:sprint/features/catalogue/domain/today_availability.dart';

class TrainerView {
  const TrainerView({
    required this.trainerId,
    required this.name,
    required this.bio,
    required this.capacity,
  });

  final String trainerId;

  /// Null when the identity record is missing; the screen shows a neutral
  /// label.
  final String? name;
  final String bio;
  final int capacity;
}

class UnitView {
  const UnitView({required this.id, required this.name, this.ownHours});

  final String id;
  final String name;

  /// Set only when this unit's weekly hours differ from the facility's.
  final List<DayHours>? ownHours;
}

class FacilityFacts {
  const FacilityFacts({
    required this.bookingWindowDays,
    this.maxRangeHours,
    this.sessionMinutes,
  });

  final int bookingWindowDays;
  final int? maxRangeHours;
  final int? sessionMinutes;
}

/// Everything the details page shows (data-model.md).
class FacilityDetails {
  const FacilityDetails({
    required this.facility,
    required this.owningUnitName,
    required this.hours,
    required this.closures,
    required this.priceGroups,
    required this.trainers,
    required this.units,
    required this.today,
    required this.facts,
  });

  final Facility facility;
  final String owningUnitName;
  final HoursView hours;
  final List<Closure> closures;
  final List<PriceGroup> priceGroups;
  final List<TrainerView> trainers;
  final List<UnitView> units;
  final TodayAvailability today;
  final FacilityFacts facts;
}
