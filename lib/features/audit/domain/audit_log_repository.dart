import 'package:sprint/features/audit/domain/audit_log.dart';

abstract interface class AuditLogRepository {
  Future<void> append(AuditLog entry);

  /// Oldest first.
  Future<List<AuditLog>> list();
}
