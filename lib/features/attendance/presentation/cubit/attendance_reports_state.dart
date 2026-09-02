import '../../data/models/attendance_report_models.dart';

sealed class AttendanceReportsState {
  const AttendanceReportsState();
}

class AttendanceReportsInitial extends AttendanceReportsState {
  const AttendanceReportsInitial();
}

class AttendanceReportsLoading extends AttendanceReportsState {
  const AttendanceReportsLoading();
}

class AttendanceReportsLoaded extends AttendanceReportsState {
  final AttendanceReportModel report;
  const AttendanceReportsLoaded(this.report);
}

class AttendanceReportsActionsLoaded extends AttendanceReportsState {
  final List<AttendanceActionReportModel> actions;
  const AttendanceReportsActionsLoaded(this.actions);
}

class AttendanceReportsPdfLoaded extends AttendanceReportsState {
  final List<int> bytes;
  const AttendanceReportsPdfLoaded(this.bytes);
}

class AttendanceReportsError extends AttendanceReportsState {
  final String message;
  const AttendanceReportsError(this.message);
}
