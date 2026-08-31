import 'package:equatable/equatable.dart';
import 'package:hr_attendance_app/features/employee/domain/entities/day_status.dart';
import 'attendance_day.dart';

class EmployeeMonthDetails extends Equatable {
  final int employeeId;
  final int year;
  final int month;
  final int totalPresentDays;
  final int annualLeaveDays;
  final int casualLeaveDays;
  final int sickLeaveDays;
  final int cutOffDays;
  final int permissionsUsed;
  final int permissionsAllowed;
  final int totalLateMinutes;
  final List<AttendanceDay> days;

  const EmployeeMonthDetails({
    required this.employeeId,
    required this.year,
    required this.month,
    required this.totalPresentDays,
    required this.annualLeaveDays,
    required this.casualLeaveDays,
    required this.sickLeaveDays,
    required this.cutOffDays,
    required this.permissionsUsed,
    required this.permissionsAllowed,
    required this.totalLateMinutes,
    required this.days,
  });

  DayStatus statusFor(DateTime date) {
    for (final d in days) {
      if (d.date.year == date.year &&
          d.date.month == date.month &&
          d.date.day == date.day) {
        return d.status;
      }
    }
    return DayStatus.none;
  }

  @override
  List<Object?> get props => [
        employeeId,
        year,
        month,
        totalPresentDays,
        annualLeaveDays,
        casualLeaveDays,
        sickLeaveDays,
        cutOffDays,
        permissionsUsed,
        permissionsAllowed,
        totalLateMinutes,
        days,
      ];
}
