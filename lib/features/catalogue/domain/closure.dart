import 'package:freezed_annotation/freezed_annotation.dart';

part 'closure.freezed.dart';

enum ClosureScope { facility, unit }

/// A period with no slots at a facility or unit (BR-05). [from] and [to] are
/// UTC instants.
@freezed
abstract class Closure with _$Closure {
  const factory Closure({
    required String id,
    required ClosureScope scope,
    required String scopeId,
    required DateTime from,
    required DateTime to,
    required String reason,
  }) = _Closure;
}
