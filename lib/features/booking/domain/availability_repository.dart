import 'package:sprint/features/booking/domain/slot.dart';

abstract interface class AvailabilityRepository {
  /// Slots of a unit from the Cairo day of [from] to the Cairo day of [to],
  /// with their state and places left. Includes active holds.
  Future<List<Slot>> slots(
    String unitId,
    DateTime from,
    DateTime to, {
    String? trainerId,
  });
}
