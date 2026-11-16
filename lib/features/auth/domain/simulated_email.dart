import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sprint/features/auth/domain/email_code.dart';

part 'simulated_email.freezed.dart';
part 'simulated_email.g.dart';

/// An email the P1 demo mailbox stores instead of sending (FR-023).
@freezed
abstract class SimulatedEmail with _$SimulatedEmail {
  const factory SimulatedEmail({
    required String id,
    required String to,
    required String subject,
    required String body,
    required CodePurpose purpose,
    required DateTime sentAt,
  }) = _SimulatedEmail;

  factory SimulatedEmail.fromJson(Map<String, dynamic> json) =>
      _$SimulatedEmailFromJson(json);
}
