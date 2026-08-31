import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_constants.dart';
import '../models/employee_model.dart';
import '../models/employee_month_details_model.dart';
import '../models/lateness_model.dart';
import '../models/mission_model.dart';
import '../models/permission_model.dart';

abstract class EmployeeRemoteDataSource {
  Future<List<EmployeeModel>> getEmployees();
  Future<EmployeeModel> getEmployeeById(int id);
  Future<EmployeeMonthDetailsModel> getMonthDetails(int employeeId, int year, int month);
  Future<List<MissionModel>> getMissions(int employeeId, int year, int month);
  Future<List<PermissionModel>> getPermissions(int employeeId, int year, int month);
  Future<List<LatenessModel>> getLateness(int employeeId, int year, int month);
}

class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  final Dio dio;
  EmployeeRemoteDataSourceImpl(this.dio);

  @override
  Future<List<EmployeeModel>> getEmployees() async {
    try {
      final response = await dio.get(ApiConstants.employees);
      final list = response.data as List<dynamic>;
      return list.map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<EmployeeModel> getEmployeeById(int id) async {
    try {
      final response = await dio.get(ApiConstants.employeeById(id));
      return EmployeeModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<EmployeeMonthDetailsModel> getMonthDetails(int employeeId, int year, int month) async {
    try {
      final response = await dio.get(
        ApiConstants.employeeDetails(employeeId),
        queryParameters: {'year': year, 'month': month},
      );
      return EmployeeMonthDetailsModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<MissionModel>> getMissions(int employeeId, int year, int month) async {
    try {
      final response = await dio.get(
        ApiConstants.employeeMissions(employeeId),
        queryParameters: {'year': year, 'month': month},
      );
      final list = response.data as List<dynamic>;
      return list.map((e) => MissionModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<PermissionModel>> getPermissions(int employeeId, int year, int month) async {
    try {
      final response = await dio.get(
        ApiConstants.employeePermissions(employeeId),
        queryParameters: {'year': year, 'month': month},
      );
      final list = response.data as List<dynamic>;
      return list.map((e) => PermissionModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<LatenessModel>> getLateness(int employeeId, int year, int month) async {
    try {
      final response = await dio.get(
        ApiConstants.employeeLateness(employeeId),
        queryParameters: {'year': year, 'month': month},
      );
      final list = response.data as List<dynamic>;
      return list.map((e) => LatenessModel.fromJson(e as Map<String, dynamic>)).toList();
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
    if (e.response?.statusCode == 404) return NotFoundException();
    return ServerException(e.message ?? 'Server error');
  }
}
