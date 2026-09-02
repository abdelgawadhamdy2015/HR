import 'package:equatable/equatable.dart';
import '../../../employee/domain/entities/day_status.dart';

/// Mirrors the .NET `AttendanceRecord` entity as returned directly by the
/// attendance action endpoints (check-in / check-out / mark / lateness).
/// Not to be confused with [AttendanceDay], which is the lighter calendar
/// summary used by `EmployeeMonthDetails`.
class AttendanceActionResult extends Equatable {
  final int id;
  final int employeeId;
  final DateTime date;
  final DayStatus status;
  final String? checkIn;
  final String? checkOut;
  final int lateMinutes;

  const AttendanceActionResult({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.status,
    this.checkIn,
    this.checkOut,
    required this.lateMinutes,
  });

  @override
  List<Object?> get props => [id, employeeId, date, status, checkIn, checkOut, lateMinutes];
}
