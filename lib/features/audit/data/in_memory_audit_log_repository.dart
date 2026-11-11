import 'package:sprint/features/audit/domain/audit_log.dart';
import 'package:sprint/features/audit/domain/audit_log_repository.dart';

class InMemoryAuditLogRepository implements AuditLogRepository {
  InMemoryAuditLogRepository([Iterable<AuditLog> seed = const []])
      : _entries = [...seed];

  final List<AuditLog> _entries;

  @override
  Future<void> append(AuditLog entry) async => _entries.add(entry);

  @override
  Future<List<AuditLog>> list() async => List.unmodifiable(_entries);
}
