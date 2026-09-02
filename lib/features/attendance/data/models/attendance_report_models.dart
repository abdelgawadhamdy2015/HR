import '../../employee/domain/entities/day_status.dart';

class AttendanceReportRequestModel {
  final DateTime fromDate;
  final DateTime toDate;
  final int? employeeId;
  final String? department;
  final DayStatus? status;
  final bool? lateOnly;

  const AttendanceReportRequestModel({
    required this.fromDate,
    required this.toDate,
    this.employeeId,
    this.department,
    this.status,
    this.lateOnly,
  });

  Map<String, dynamic> toQueryParameters() {
    return {
      'fromDate': _date(fromDate),
      'toDate': _date(toDate),
      if (employeeId != null) 'employeeId': employeeId,
      if (department != null && department!.trim().isNotEmpty) 'department': department,
      if (status != null && status != DayStatus.none) 'status': _status(status!),
      if (lateOnly != null) 'lateOnly': lateOnly,
    };
  }

  static String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  static String _status(DayStatus value) {
    switch (value) {
      case DayStatus.present: return 'Present';
      case DayStatus.annualLeave: return 'AnnualLeave';
      case DayStatus.casualLeave: return 'CasualLeave';
      case DayStatus.sickLeave: return 'SickLeave';
      case DayStatus.permission: return 'Permission';
      case DayStatus.cutOff: return 'CutOff';
      case DayStatus.mission: return 'Mission';
      case DayStatus.none: return 'None';
    }
  }
}

class AttendanceReportModel {
  final DateTime fromDate;
  final DateTime toDate;
  final int employeeCount;
  final int workingDays;
  final int totalRecords;
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final int totalLateMinutes;
  final int totalWorkedMinutes;
  final List<EmployeeAttendanceReportModel> employees;

  const AttendanceReportModel({
    required this.fromDate,
    required this.toDate,
    required this.employeeCount,
    required this.workingDays,
    required this.totalRecords,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.totalLateMinutes,
    required this.totalWorkedMinutes,
    required this.employees,
  });

  factory AttendanceReportModel.fromJson(Map<String, dynamic> json) {
    return AttendanceReportModel(
      fromDate: DateTime.parse(json['fromDate'] as String),
      toDate: DateTime.parse(json['toDate'] as String),
      employeeCount: json['employeeCount'] as int,
      workingDays: json['workingDays'] as int,
      totalRecords: json['totalRecords'] as int,
      presentDays: json['presentDays'] as int,
      absentDays: json['absentDays'] as int,
      lateDays: json['lateDays'] as int,
      totalLateMinutes: json['totalLateMinutes'] as int,
      totalWorkedMinutes: json['totalWorkedMinutes'] as int,
      employees: (json['employees'] as List<dynamic>? ?? [])
          .map((e) => EmployeeAttendanceReportModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class EmployeeAttendanceReportModel {
  final int employeeId;
  final String code;
  final String fullName;
  final String jobTitle;
  final String department;
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final int totalLateMinutes;
  final int totalWorkedMinutes;
  final List<AttendanceDayReportModel> days;

  const EmployeeAttendanceReportModel({
    required this.employeeId,
    required this.code,
    required this.fullName,
    required this.jobTitle,
    required this.department,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.totalLateMinutes,
    required this.totalWorkedMinutes,
    required this.days,
  });

  factory EmployeeAttendanceReportModel.fromJson(Map<String, dynamic> json) {
    return EmployeeAttendanceReportModel(
      employeeId: json['employeeId'] as int,
      code: json['code'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      jobTitle: json['jobTitle'] as String? ?? '',
      department: json['department'] as String? ?? '',
      presentDays: json['presentDays'] as int,
      absentDays: json['absentDays'] as int,
      lateDays: json['lateDays'] as int,
      totalLateMinutes: json['totalLateMinutes'] as int,
      totalWorkedMinutes: json['totalWorkedMinutes'] as int,
      days: (json['days'] as List<dynamic>? ?? [])
          .map((e) => AttendanceDayReportModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AttendanceDayReportModel {
  final DateTime date;
  final DayStatus status;
  final String? checkIn;
  final String? checkOut;
  final int lateMinutes;
  final int workedMinutes;

  const AttendanceDayReportModel({
    required this.date,
    required this.status,
    this.checkIn,
    this.checkOut,
    required this.lateMinutes,
    required this.workedMinutes,
  });

  factory AttendanceDayReportModel.fromJson(Map<String, dynamic> json) {
    return AttendanceDayReportModel(
      date: DateTime.parse(json['date'] as String),
      status: DayStatusX.fromApi(json['status'] as String? ?? 'none'),
      checkIn: json['checkIn'] as String?,
      checkOut: json['checkOut'] as String?,
      lateMinutes: json['lateMinutes'] as int? ?? 0,
      workedMinutes: json['workedMinutes'] as int? ?? 0,
    );
  }
}

class AttendanceActionReportModel {
  final int employeeId;
  final String employeeCode;
  final String employeeName;
  final DateTime date;
  final String actionType;
  final String? time;
  final String? details;

  const AttendanceActionReportModel({
    required this.employeeId,
    required this.employeeCode,
    required this.employeeName,
    required this.date,
    required this.actionType,
    this.time,
    this.details,
  });

  factory AttendanceActionReportModel.fromJson(Map<String, dynamic> json) {
    return AttendanceActionReportModel(
      employeeId: json['employeeId'] as int,
      employeeCode: json['employeeCode'] as String? ?? '',
      employeeName: json['employeeName'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      actionType: json['actionType'] as String? ?? '',
      time: json['time'] as String?,
      details: json['details'] as String?,
    );
  }
}
