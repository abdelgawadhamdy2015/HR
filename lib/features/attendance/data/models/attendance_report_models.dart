import '../../../employee/domain/entities/day_status.dart';

class AttendanceReportRequestModel {
  final DateTime fromDate, toDate;
  final int? employeeId;
  final String? department;
  final DayStatus? status;
  final bool? lateOnly;
  const AttendanceReportRequestModel({required this.fromDate, required this.toDate, this.employeeId, this.department, this.status, this.lateOnly});
  Map<String, dynamic> toQueryParameters() => {'fromDate': _date(fromDate), 'toDate': _date(toDate), if (employeeId != null) 'employeeId': employeeId, if (department != null && department!.trim().isNotEmpty) 'department': department, if (status != null && status != DayStatus.none) 'status': _status(status!), if (lateOnly != null) 'lateOnly': lateOnly};
  static String _date(DateTime v) => '${v.year.toString().padLeft(4, '0')}-${v.month.toString().padLeft(2, '0')}-${v.day.toString().padLeft(2, '0')}';
  static String _status(DayStatus v) { switch (v) { case DayStatus.present: return 'Present'; case DayStatus.annualLeave: return 'AnnualLeave'; case DayStatus.casualLeave: return 'CasualLeave'; case DayStatus.sickLeave: return 'SickLeave'; case DayStatus.permission: return 'Permission'; case DayStatus.cutOff: return 'CutOff'; case DayStatus.mission: return 'Mission'; case DayStatus.none: return 'None'; } }
}

class AttendanceReportModel {
  final DateTime fromDate, toDate; final int employeeCount, workingDays, totalRecords, presentDays, absentDays, lateDays, totalLateMinutes, totalWorkedMinutes; final List<EmployeeAttendanceReportModel> employees;
  const AttendanceReportModel({required this.fromDate, required this.toDate, required this.employeeCount, required this.workingDays, required this.totalRecords, required this.presentDays, required this.absentDays, required this.lateDays, required this.totalLateMinutes, required this.totalWorkedMinutes, required this.employees});
  factory AttendanceReportModel.fromJson(Map<String, dynamic> j) => AttendanceReportModel(fromDate: DateTime.parse(j['fromDate'] as String), toDate: DateTime.parse(j['toDate'] as String), employeeCount: j['employeeCount'] as int, workingDays: j['workingDays'] as int, totalRecords: j['totalRecords'] as int, presentDays: j['presentDays'] as int, absentDays: j['absentDays'] as int, lateDays: j['lateDays'] as int, totalLateMinutes: j['totalLateMinutes'] as int, totalWorkedMinutes: j['totalWorkedMinutes'] as int, employees: (j['employees'] as List<dynamic>? ?? []).map((e) => EmployeeAttendanceReportModel.fromJson(Map<String, dynamic>.from(e as Map))).toList());
}

class EmployeeAttendanceReportModel {
  final int employeeId; final String code, fullName, jobTitle, department; final int presentDays, absentDays, lateDays, totalLateMinutes, totalWorkedMinutes; final List<AttendanceDayReportModel> days;
  const EmployeeAttendanceReportModel({required this.employeeId, required this.code, required this.fullName, required this.jobTitle, required this.department, required this.presentDays, required this.absentDays, required this.lateDays, required this.totalLateMinutes, required this.totalWorkedMinutes, required this.days});
  factory EmployeeAttendanceReportModel.fromJson(Map<String, dynamic> j) => EmployeeAttendanceReportModel(employeeId: j['employeeId'] as int, code: j['code'] as String? ?? '', fullName: j['fullName'] as String? ?? '', jobTitle: j['jobTitle'] as String? ?? '', department: j['department'] as String? ?? '', presentDays: j['presentDays'] as int, absentDays: j['absentDays'] as int, lateDays: j['lateDays'] as int, totalLateMinutes: j['totalLateMinutes'] as int, totalWorkedMinutes: j['totalWorkedMinutes'] as int, days: (j['days'] as List<dynamic>? ?? []).map((e) => AttendanceDayReportModel.fromJson(Map<String, dynamic>.from(e as Map))).toList());
}

class AttendanceDayReportModel {
  final DateTime date; final DayStatus status; final String? checkIn, checkOut; final int lateMinutes, workedMinutes;
  const AttendanceDayReportModel({required this.date, required this.status, this.checkIn, this.checkOut, required this.lateMinutes, required this.workedMinutes});
  factory AttendanceDayReportModel.fromJson(Map<String, dynamic> j) => AttendanceDayReportModel(date: DateTime.parse(j['date'] as String), status: DayStatusX.fromApi(j['status'] as String? ?? 'none'), checkIn: j['checkIn'] as String?, checkOut: j['checkOut'] as String?, lateMinutes: j['lateMinutes'] as int? ?? 0, workedMinutes: j['workedMinutes'] as int? ?? 0);
}

class AttendanceActionReportModel {
  final int employeeId; final String employeeCode, employeeName; final DateTime date; final String actionType; final String? time, details;
  const AttendanceActionReportModel({required this.employeeId, required this.employeeCode, required this.employeeName, required this.date, required this.actionType, this.time, this.details});
  factory AttendanceActionReportModel.fromJson(Map<String, dynamic> j) => AttendanceActionReportModel(employeeId: j['employeeId'] as int, employeeCode: j['employeeCode'] as String? ?? '', employeeName: j['employeeName'] as String? ?? '', date: DateTime.parse(j['date'] as String), actionType: j['actionType'] as String? ?? '', time: j['time'] as String?, details: j['details'] as String?);
}
