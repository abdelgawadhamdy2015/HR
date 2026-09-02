import '../../../../core/utils/result.dart';
import '../../data/models/attendance_report_models.dart';
import '../repositories/attendance_reports_repository.dart';

class GetAttendanceReport {
  final AttendanceReportsRepository repository;
  GetAttendanceReport(this.repository);

  Future<Result<AttendanceReportModel>> call(AttendanceReportRequestModel request) =>
      repository.getReport(request);
}
