import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_constants.dart';
import '../models/attendance_report_models.dart';

abstract class AttendanceReportsRemoteDataSource {
  Future<AttendanceReportModel> getReport(AttendanceReportRequestModel request);
  Future<List<AttendanceActionReportModel>> getActions(AttendanceReportRequestModel request);
  Future<List<int>> getPdf(AttendanceReportRequestModel request);
  Future<List<int>> getEmployeePdf(int employeeId, DateTime fromDate, DateTime toDate);
}

class AttendanceReportsRemoteDataSourceImpl implements AttendanceReportsRemoteDataSource {
  final Dio dio;
  AttendanceReportsRemoteDataSourceImpl(this.dio);

  @override
  Future<AttendanceReportModel> getReport(AttendanceReportRequestModel request) async {
    try {
      final response = await dio.get(
        ApiConstants.attendanceReports,
        queryParameters: request.toQueryParameters(),
      );
      return AttendanceReportModel.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) { throw _mapDioError(e); }
  }

  @override
  Future<List<AttendanceActionReportModel>> getActions(AttendanceReportRequestModel request) async {
    try {
      final response = await dio.get(
        ApiConstants.attendanceReportActions,
        queryParameters: request.toQueryParameters(),
      );
      final data = response.data is List ? response.data as List : <dynamic>[];
      return data.map((e) => AttendanceActionReportModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } on DioException catch (e) { throw _mapDioError(e); }
  }

  @override
  Future<List<int>> getPdf(AttendanceReportRequestModel request) async {
    try {
      final response = await dio.get<List<int>>(
        ApiConstants.attendanceReportPdf,
        queryParameters: request.toQueryParameters(),
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data ?? <int>[];
    } on DioException catch (e) { throw _mapDioError(e); }
  }

  @override
  Future<List<int>> getEmployeePdf(int employeeId, DateTime fromDate, DateTime toDate) async {
    try {
      final response = await dio.get<List<int>>(
        ApiConstants.attendanceReportEmployeePdf(employeeId),
        queryParameters: AttendanceReportRequestModel(
          fromDate: fromDate,
          toDate: toDate,
        ).toQueryParameters(),
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data ?? <int>[];
    } on DioException catch (e) { throw _mapDioError(e); }
  }

  Exception _mapDioError(DioException e) {
    final status = e.response?.statusCode;
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException();
    }
    if (status == 404) return NotFoundException('Not found');
    if (status == 403) return ForbiddenException('Forbidden');
    if (status == 400) return ValidationException('Invalid request');
    return ServerException(e.message ?? 'Server error');
  }
}
