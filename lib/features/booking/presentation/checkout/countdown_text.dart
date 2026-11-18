/// "9:42" for a countdown: whole minutes, a colon and two-digit seconds.
/// Western digits, whatever the language (CLAUDE.md copy rules).
String countdownText(Duration remaining) {
  final total = remaining.isNegative ? 0 : remaining.inSeconds;
  final m = total ~/ 60;
  final s = (total % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// The part of the Hold the screen reader should hear again: it changes only
/// every 30 seconds and once on entering the last minute, never every second
/// (FR-031). Higher values are earlier in the countdown.
int announcementBoundary(Duration remaining, {required Duration lastMinute}) =>
    remaining < lastMinute ? -1 : remaining.inSeconds ~/ 30;
