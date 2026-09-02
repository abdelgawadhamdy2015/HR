import '../../../employee/domain/entities/day_status.dart';

class AttendanceReportRequestModel {
  final DateTime fromDate, toDate;
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

  Map<String, dynamic> toQueryParameters() => {
        'fromDate': _date(fromDate),
        'toDate': _date(toDate),
        if (employeeId != null) 'employeeId': employeeId,
        if (department != null && department!.trim().isNotEmpty)
          'department': department!.trim(),
        if (status != null && status != DayStatus.none) 'status': _status(status!),
        if (lateOnly != null) 'lateOnly': lateOnly,
      };

  static String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  static String _status(DayStatus value) {
    switch (value) {
      case DayStatus.present:
        return 'Present';
      case DayStatus.annualLeave:
        return 'AnnualLeave';
      case DayStatus.casualLeave:
        return 'CasualLeave';
      case DayStatus.sickLeave:
        return 'SickLeave';
      case DayStatus.permission:
        return 'Permission';
      case DayStatus.cutOff:
        return 'CutOff';
      case DayStatus.mission:
        return 'Mission';
      case DayStatus.none:
        return 'None';
    }
  }
}

class AttendanceReportModel {
  final DateTime fromDate, toDate;
  final int employeeCount, workingDays, totalRecords, presentDays, absentDays;
  final int lateDays, totalLateMinutes, totalWorkedMinutes;
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
      fromDate: _dateTime(json['fromDate']),
      toDate: _dateTime(json['toDate']),
      employeeCount: _int(json['employeeCount']),
      workingDays: _int(json['workingDays']),
      totalRecords: _int(json['totalRecords']),
      presentDays: _int(json['presentDays']),
      absentDays: _int(json['absentDays']),
      lateDays: _int(json['lateDays']),
      totalLateMinutes: _int(json['totalLateMinutes']),
      totalWorkedMinutes: _int(json['totalWorkedMinutes']),
      employees: _list(json['employees'])
          .map(EmployeeAttendanceReportModel.fromJson)
          .toList(),
    );
  }
}

class EmployeeAttendanceReportModel {
  final int employeeId;
  final String code, fullName, jobTitle, department;
  final int presentDays, absentDays, lateDays, totalLateMinutes, totalWorkedMinutes;
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
      employeeId: _int(json['employeeId']),
      code: _string(json['code']),
      fullName: _string(json['fullName']),
      jobTitle: _string(json['jobTitle']),
      department: _string(json['department']),
      presentDays: _int(json['presentDays']),
      absentDays: _int(json['absentDays']),
      lateDays: _int(json['lateDays']),
      totalLateMinutes: _int(json['totalLateMinutes']),
      totalWorkedMinutes: _int(json['totalWorkedMinutes']),
      days: _list(json['days']).map(AttendanceDayReportModel.fromJson).toList(),
    );
  }
}

class AttendanceDayReportModel {
  final DateTime date;
  final DayStatus status;
  final String? checkIn, checkOut;
  final int lateMinutes, workedMinutes;

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
      date: _dateTime(json['date']),
      status: _dayStatus(json['status']),
      checkIn: _nullableString(json['checkIn']),
      checkOut: _nullableString(json['checkOut']),
      lateMinutes: _int(json['lateMinutes']),
      workedMinutes: _int(json['workedMinutes']),
    );
  }
}

class AttendanceActionReportModel {
  final int employeeId;
  final String employeeCode, employeeName;
  final DateTime date;
  final String actionType;
  final String? time, details;

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
      employeeId: _int(json['employeeId']),
      employeeCode: _string(json['employeeCode']),
      employeeName: _string(json['employeeName']),
      date: _dateTime(json['date']),
      actionType: _string(json['actionType']),
      time: _nullableString(json['time']),
      details: _nullableString(json['details']),
    );
  }
}

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _string(dynamic value) => value?.toString() ?? '';

String? _nullableString(dynamic value) => value == null ? null : value.toString();

DateTime _dateTime(dynamic value) {
  if (value is DateTime) return value;
  return DateTime.tryParse(value?.toString() ?? '') ?? DateTime(1970);
}

List<Map<String, dynamic>> _list(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

DayStatus _dayStatus(dynamic value) {
  if (value is int) return _statusFromIndex(value);
  if (value is num) return _statusFromIndex(value.toInt());

  final normalized = value?.toString().trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) return DayStatus.none;

  switch (normalized.replaceAll('_', '').replaceAll('-', '')) {
    case '0':
      return DayStatus.none;
    case '1':
    case 'present':
      return DayStatus.present;
    case '2':
    case 'annualleave':
      return DayStatus.annualLeave;
    case '3':
    case 'casualleave':
      return DayStatus.casualLeave;
    case '4':
    case 'sickleave':
      return DayStatus.sickLeave;
    case '5':
    case 'permission':
      return DayStatus.permission;
    case '6':
    case 'cutoff':
      return DayStatus.cutOff;
    case '7':
    case 'mission':
      return DayStatus.mission;
    default:
      return DayStatusX.fromApi(value.toString());
  }
}

DayStatus _statusFromIndex(int value) {
  if (value >= 0 && value < DayStatus.values.length) {
    return DayStatus.values[value];
  }
  return DayStatus.none;
}
