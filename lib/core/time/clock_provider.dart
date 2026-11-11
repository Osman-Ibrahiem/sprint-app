import 'package:clock/clock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock_provider.g.dart';

/// The injected "now". Rules never read the system time directly; tests
/// override this provider with a fixed clock.
@Riverpod(keepAlive: true)
Clock appClock(Ref ref) => const Clock();
