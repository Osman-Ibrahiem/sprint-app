import 'package:sprint/core/data/change_signal.dart';
import 'package:sprint/features/audit/domain/audit_log.dart';
import 'package:sprint/features/audit/domain/audit_log_repository.dart';

class InMemoryAuditLogRepository with ChangeSignal implements AuditLogRepository {
  InMemoryAuditLogRepository([Iterable<AuditLog> seed = const []])
      : _entries = [...seed];

  final List<AuditLog> _entries;

  @override
  Future<void> append(AuditLog entry) async {
    _entries.add(entry);
    notifyChanged();
  }

  /// Everything, for the demo snapshot.
  List<AuditLog> get all => List.unmodifiable(_entries);

  @override
  Future<List<AuditLog>> list() async => List.unmodifiable(_entries);
}
