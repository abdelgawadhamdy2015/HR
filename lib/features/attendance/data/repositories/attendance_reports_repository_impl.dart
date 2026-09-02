import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/attendance_reports_repository.dart';
import '../datasources/attendance_reports_remote_data_source.dart';
import '../models/attendance_report_models.dart';

class AttendanceReportsRepositoryImpl implements AttendanceReportsRepository {
  final AttendanceReportsRemoteDataSource remoteDataSource;
  AttendanceReportsRepositoryImpl(this.remoteDataSource);

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on NetworkException catch (e) { return Error(NetworkFailure(e.message)); }
    on NotFoundException catch (e) { return Error(NotFoundFailure(e.message)); }
    on ValidationException catch (e) { return Error(ValidationFailure(e.message)); }
    on ForbiddenException catch (e) { return Error(ForbiddenFailure(e.message)); }
    on ServerException catch (e) { return Error(ServerFailure(e.message)); }
    catch (_) { return const Error(UnknownFailure()); }
  }

  @override
  Future<Result<AttendanceReportModel>> getReport(AttendanceReportRequestModel request) =>
      _guard(() => remoteDataSource.getReport(request));

  @override
  Future<Result<List<AttendanceActionReportModel>>> getActions(AttendanceReportRequestModel request) =>
      _guard(() => remoteDataSource.getActions(request));

  @override
  Future<Result<List<int>>> getPdf(AttendanceReportRequestModel request) =>
      _guard(() => remoteDataSource.getPdf(request));

  @override
  Future<Result<List<int>>> getEmployeePdf(int employeeId, DateTime fromDate, DateTime toDate) =>
      _guard(() => remoteDataSource.getEmployeePdf(employeeId, fromDate, toDate));
}
