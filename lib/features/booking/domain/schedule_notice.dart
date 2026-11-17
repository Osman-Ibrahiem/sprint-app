import 'package:sprint/core/result/failure.dart';

/// The booking an overlap refusal names (BR-13), looked up by the screen.
class OverlapInfo {
  const OverlapInfo({
    required this.facilityName,
    required this.start,
    required this.end,
  });

  final String facilityName;

  /// UTC instants.
  final DateTime start;
  final DateTime end;
}

/// What the inline notice above the grid says (feature 005 research R11):
/// either a refusal from the repositories, or that an earlier choice from the
/// address is no longer available.
class ScheduleNotice {
  const ScheduleNotice.failure(Failure this.failure, {this.overlap})
    : choiceGone = false;

  const ScheduleNotice.choiceNoLongerAvailable()
    : failure = null,
      overlap = null,
      choiceGone = true;

  final Failure? failure;
  final OverlapInfo? overlap;
  final bool choiceGone;
}
