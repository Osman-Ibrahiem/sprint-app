import 'package:freezed_annotation/freezed_annotation.dart';

part 'trainer_availability.freezed.dart';

/// Where and when a trainer is available (BR-09). Cairo wall-clock minutes.
@freezed
abstract class TrainerAvailability with _$TrainerAvailability {
  const factory TrainerAvailability({
    required String trainerId,
    required String unitId,
    required int dayOfWeek,
    required int fromMinutes,
    required int toMinutes,
  }) = _TrainerAvailability;
}
