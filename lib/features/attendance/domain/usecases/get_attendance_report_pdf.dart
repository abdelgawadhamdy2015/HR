import '../../../../core/utils/result.dart';
import '../../data/models/attendance_report_models.dart';
import '../repositories/attendance_reports_repository.dart';

class GetAttendanceReportPdf {
  final AttendanceReportsRepository repository;
  GetAttendanceReportPdf(this.repository);

  Future<Result<List<int>>> call(AttendanceReportRequestModel request) =>
      repository.getPdf(request);
}
