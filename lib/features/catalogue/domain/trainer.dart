import 'package:freezed_annotation/freezed_annotation.dart';

part 'trainer.freezed.dart';
part 'trainer.g.dart';

@freezed
abstract class Trainer with _$Trainer {
  const factory Trainer({
    required String id,
    required String userId,
    required List<String> facilityIds,
    required String bio,
    required int trainerCapacity,
  }) = _Trainer;

  factory Trainer.fromJson(Map<String, dynamic> json) =>
      _$TrainerFromJson(json);
}
