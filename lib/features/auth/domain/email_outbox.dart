import 'package:sprint/features/auth/domain/simulated_email.dart';

/// Where emails go. P1 stores them in the simulated mailbox; a real email
/// provider sends them later (FR-023).
abstract interface class EmailOutbox {
  Future<void> send(SimulatedEmail email);
}
