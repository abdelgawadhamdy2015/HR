import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_constants.dart';
import '../../../employee/data/models/mission_model.dart';
import '../../../employee/data/models/permission_model.dart';
import '../models/attendance_action_result_model.dart';

abstract class AttendanceActionsRemoteDataSource {
  Future<AttendanceActionResultModel> checkIn(Map<String, dynamic> body);
  Future<AttendanceActionResultModel> checkOut(Map<String, dynamic> body);
  Future<AttendanceActionResultModel> markDay(Map<String, dynamic> body);
  Future<AttendanceActionResultModel> recordLateness(Map<String, dynamic> body);
  Future<MissionModel> createMission(Map<String, dynamic> body);
  Future<PermissionModel> createPermissionRequest(Map<String, dynamic> body);
}

class AttendanceActionsRemoteDataSourceImpl implements AttendanceActionsRemoteDataSource {
  final Dio dio;
  AttendanceActionsRemoteDataSourceImpl(this.dio);

  @override
  Future<AttendanceActionResultModel> checkIn(Map<String, dynamic> body) async {
    try {
      final response = await dio.post(ApiConstants.attendanceCheckIn, data: body);
      return AttendanceActionResultModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<AttendanceActionResultModel> checkOut(Map<String, dynamic> body) async {
    try {
      final response = await dio.post(ApiConstants.attendanceCheckOut, data: body);
      return AttendanceActionResultModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<AttendanceActionResultModel> markDay(Map<String, dynamic> body) async {
    try {
      final response = await dio.post(ApiConstants.attendanceMark, data: body);
      return AttendanceActionResultModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<AttendanceActionResultModel> recordLateness(Map<String, dynamic> body) async {
    try {
      final response = await dio.post(ApiConstants.attendanceLateness, data: body);
      return AttendanceActionResultModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<MissionModel> createMission(Map<String, dynamic> body) async {
    try {
      final response = await dio.post(ApiConstants.missions, data: body);
      return MissionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<PermissionModel> createPermissionRequest(Map<String, dynamic> body) async {
    try {
      final response = await dio.post(ApiConstants.permissionRequests, data: body);
      return PermissionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Exception _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException();
    }

    final status = e.response?.statusCode;
    final data = e.response?.data;
    String? message;
    if (data is String && data.isNotEmpty) {
      message = data;
    } else if (data is Map && data['message'] != null) {
      message = data['message'].toString();
    }

    if (status == 404) return NotFoundException(message ?? 'Not found');
    if (status == 409) return ConflictException(message ?? 'Conflict');
    if (status == 400) return ValidationException(message ?? 'Invalid request');
    if (status == 403) return ForbiddenException(message ?? 'Forbidden');
    return ServerException(message ?? e.message ?? 'Server error');
  }
}
