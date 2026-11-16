import 'dart:async';

/// The `changes` stream every in-memory repository exposes: it fires after
/// each successful write, so the session, the screens and the snapshot save
/// refresh (research R9, R1).
mixin ChangeSignal {
  final StreamController<void> _signal = StreamController<void>.broadcast();

  Stream<void> get changes => _signal.stream;

  void notifyChanged() {
    if (!_signal.isClosed) _signal.add(null);
  }
}
