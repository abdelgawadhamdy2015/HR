import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_constants.dart';
import '../models/attendance_report_models.dart';

abstract class AttendanceReportsRemoteDataSource {
  Future<AttendanceReportModel> getReport(AttendanceReportRequestModel request);
  Future<AttendanceReportModel> getDailyReport({
    required DateTime date,
    int? employeeId,
    String? department,
  });
  Future<AttendanceReportModel> getLateReport(AttendanceReportRequestModel request);
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
      return AttendanceReportModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<AttendanceReportModel> getDailyReport({
    required DateTime date,
    int? employeeId,
    String? department,
  }) async {
    try {
      final query = <String, dynamic>{
        'date': _date(date),
        if (employeeId != null) 'employeeId': employeeId,
        if (department != null && department.trim().isNotEmpty)
          'department': department.trim(),
      };
      final response = await dio.get(
        ApiConstants.attendanceReportDaily,
        queryParameters: query,
      );
      return AttendanceReportModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<AttendanceReportModel> getLateReport(
    AttendanceReportRequestModel request,
  ) async {
    try {
      final response = await dio.get(
        ApiConstants.attendanceReportLate,
        queryParameters: request.toQueryParameters(),
      );
      return AttendanceReportModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<AttendanceActionReportModel>> getActions(
    AttendanceReportRequestModel request,
  ) async {
    try {
      final response = await dio.get(
        ApiConstants.attendanceReportActions,
        queryParameters: request.toQueryParameters(),
      );
      final data = response.data is List ? response.data as List : <dynamic>[];
      return data
          .map(
            (e) => AttendanceActionReportModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
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
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<int>> getEmployeePdf(
    int employeeId,
    DateTime fromDate,
    DateTime toDate,
  ) async {
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
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  Exception _mapDioError(DioException e) {
    final status = e.response?.statusCode;
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException();
    }
    if (status == 404) return NotFoundException('Not found');
    if (status == 403) return ForbiddenException('Forbidden');
    if (status == 400) {
      final data = e.response?.data;
      final message = data is Map
          ? data['message']?.toString() ?? 'Invalid request'
          : 'Invalid request';
      return ValidationException(message);
    }
    return ServerException(e.message ?? 'Server error');
  }
}
