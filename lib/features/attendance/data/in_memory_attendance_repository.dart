import 'package:sprint/core/data/change_signal.dart';
import 'package:sprint/features/attendance/domain/attendance.dart';
import 'package:sprint/features/attendance/domain/attendance_repository.dart';

class InMemoryAttendanceRepository
    with ChangeSignal
    implements AttendanceRepository {
  InMemoryAttendanceRepository([Iterable<Attendance> seed = const []])
      : _items = {for (final a in seed) a.bookingId: a};

  final Map<String, Attendance> _items;

  @override
  Future<Attendance?> forBooking(String bookingId) async => _items[bookingId];

  @override
  Future<List<Attendance>> list() async => _items.values.toList();

  @override
  Future<void> save(Attendance attendance) async {
    _items[attendance.bookingId] = attendance;
    notifyChanged();
  }

  /// Everything, for the demo snapshot.
  List<Attendance> get all => _items.values.toList();
}
