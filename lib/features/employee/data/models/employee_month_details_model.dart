import '../../domain/entities/attendance_day.dart';
import '../../domain/entities/day_status.dart';
import '../../domain/entities/employee_month_details.dart';

class AttendanceDayModel extends AttendanceDay {
  const AttendanceDayModel({required super.date, required super.status});

  factory AttendanceDayModel.fromJson(Map<String, dynamic> json) {
    return AttendanceDayModel(
      date: DateTime.parse(json['date'] as String),
      status: DayStatusX.fromApi(json['status'] as String),
    );
  }
}

class EmployeeMonthDetailsModel extends EmployeeMonthDetails {
  const EmployeeMonthDetailsModel({
    required super.employeeId,
    required super.year,
    required super.month,
    required super.totalPresentDays,
    required super.annualLeaveDays,
    required super.casualLeaveDays,
    required super.sickLeaveDays,
    required super.cutOffDays,
    required super.permissionsUsed,
    required super.permissionsAllowed,
    required super.totalLateMinutes,
    required super.days,
  });

  factory EmployeeMonthDetailsModel.fromJson(Map<String, dynamic> json) {
    return EmployeeMonthDetailsModel(
      employeeId: json['employeeId'] as int,
      year: json['year'] as int,
      month: json['month'] as int,
      totalPresentDays: json['totalPresentDays'] as int,
      annualLeaveDays: json['annualLeaveDays'] as int,
      casualLeaveDays: json['casualLeaveDays'] as int,
      sickLeaveDays: json['sickLeaveDays'] as int,
      cutOffDays: json['cutOffDays'] as int,
      permissionsUsed: json['permissionsUsed'] as int,
      permissionsAllowed: json['permissionsAllowed'] as int,
      totalLateMinutes: json['totalLateMinutes'] as int,
      days: (json['days'] as List<dynamic>)
          .map((e) => AttendanceDayModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
