import '../../../../core/utils/result.dart';
import '../../data/models/attendance_report_models.dart';

abstract class AttendanceReportsRepository {
  Future<Result<AttendanceReportModel>> getReport(AttendanceReportRequestModel request);
  Future<Result<AttendanceReportModel>> getDailyReport({required DateTime date, int? employeeId, String? department});
  Future<Result<AttendanceReportModel>> getLateReport(AttendanceReportRequestModel request);
  Future<Result<AttendanceReportModel>> getEmployeeReport(int employeeId, DateTime fromDate, DateTime toDate);
  Future<Result<List<AttendanceActionReportModel>>> getActions(AttendanceReportRequestModel request);
  Future<Result<List<int>>> getPdf(AttendanceReportRequestModel request);
  Future<Result<List<int>>> getEmployeePdf(int employeeId, DateTime fromDate, DateTime toDate);
}
