import 'package:freezed_annotation/freezed_annotation.dart';

part 'audit_log.freezed.dart';

/// One administrative change (BRD §5).
@freezed
abstract class AuditLog with _$AuditLog {
  const factory AuditLog({
    required String actorId,
    required String action,
    required String entity,
    required String entityId,
    String? before,
    String? after,
    required DateTime at,
  }) = _AuditLog;
}
