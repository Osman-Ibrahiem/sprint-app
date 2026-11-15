import 'package:flutter/material.dart';

/// The value object the day strip takes (data-model.md): a Cairo date only,
/// whether the day has room, and whether the facility is closed.
@immutable
class DayStripDay {
  const DayStripDay({
    required this.date,
    required this.hasAvailability,
    this.isClosed = false,
  });

  final DateTime date;
  final bool hasAvailability;
  final bool isClosed;

  @override
  bool operator ==(Object other) =>
      other is DayStripDay &&
      other.date == date &&
      other.hasAvailability == hasAvailability &&
      other.isClosed == isClosed;

  @override
  int get hashCode => Object.hash(date, hasAvailability, isClosed);
}
