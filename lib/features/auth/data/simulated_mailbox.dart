// ignore_for_file: prefer_initializing_formals

import 'package:sprint/core/data/change_signal.dart';
import 'package:sprint/features/auth/domain/email_code.dart';
import 'package:sprint/features/auth/domain/email_outbox.dart';
import 'package:sprint/features/auth/domain/simulated_email.dart';

/// Builds the localised subject and body for a code email. Passed in at
/// construction (reading the app's current language when called) so the data
/// layer never needs a `BuildContext`. The body MUST contain [code].
typedef EmailTemplate = ({String subject, String body}) Function(
  CodePurpose purpose,
  String code,
);

final RegExp _codePattern = RegExp(r'(?<![0-9])[0-9]{6}(?![0-9])');

/// The P1 [EmailOutbox]: keeps emails instead of sending them (FR-023).
///
/// Convention with the auth repository: it calls `send` with a
/// [SimulatedEmail] whose `body` is the bare code; the mailbox replaces
/// `subject` and `body` with the localised template and stores the result.
class SimulatedMailbox with ChangeSignal implements EmailOutbox {
  SimulatedMailbox({
    required EmailTemplate template,
    Iterable<SimulatedEmail> emails = const [],
  }) : _template = template,
       _emails = [...emails];

  final EmailTemplate _template;
  final List<SimulatedEmail> _emails; // oldest first

  @override
  Future<void> send(SimulatedEmail email) async {
    final text = _template(email.purpose, email.body);
    _emails.add(email.copyWith(subject: text.subject, body: text.body));
    notifyChanged();
  }

  /// Every stored email, newest first.
  List<SimulatedEmail> list() => _emails.reversed.toList(growable: false);

  /// The code in the newest email to [email] for [purpose], or null.
  String? latestCodeFor(String email, CodePurpose purpose) {
    final to = email.trim().toLowerCase();
    for (final m in _emails.reversed) {
      if (m.to.toLowerCase() == to && m.purpose == purpose) {
        return _codePattern.firstMatch(m.body)?.group(0);
      }
    }
    return null;
  }

  /// For the demo snapshot.
  List<Map<String, dynamic>> toJson() => [for (final m in _emails) m.toJson()];

  static List<SimulatedEmail> emailsFromJson(List<dynamic> json) => [
    for (final m in json) SimulatedEmail.fromJson(m as Map<String, dynamic>),
  ];

  /// Demo reset.
  void clear() {
    _emails.clear();
    notifyChanged();
  }
}
