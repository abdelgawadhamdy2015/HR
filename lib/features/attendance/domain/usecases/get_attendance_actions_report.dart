import '../../../../core/utils/result.dart';
import '../../data/models/attendance_report_models.dart';
import '../repositories/attendance_reports_repository.dart';

class GetAttendanceActionsReport {
  final AttendanceReportsRepository repository;
  GetAttendanceActionsReport(this.repository);

  Future<Result<List<AttendanceActionReportModel>>> call(AttendanceReportRequestModel request) =>
      repository.getActions(request);
}
