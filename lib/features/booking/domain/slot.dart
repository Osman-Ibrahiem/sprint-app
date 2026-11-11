/// How a slot looks to the person choosing it.
enum SlotState { available, fewLeft, full, past, closed }

/// A computed slot (BRD §5: slots are computed, bookings are stored).
class Slot {
  const Slot({
    required this.start,
    required this.end,
    required this.state,
    required this.remaining,
    required this.capacity,
  });

  /// UTC instants.
  final DateTime start;
  final DateTime end;
  final SlotState state;

  /// Places left (0 when full, past or closed).
  final int remaining;
  final int capacity;

  bool get isBookable =>
      state == SlotState.available || state == SlotState.fewLeft;

  @override
  String toString() => 'Slot($start, $state, $remaining/$capacity)';
}
