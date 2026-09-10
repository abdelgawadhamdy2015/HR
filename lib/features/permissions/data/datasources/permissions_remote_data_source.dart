import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_constants.dart';
import '../models/permission_model.dart';

abstract class PermissionsRemoteDataSource {
  Future<List<PermissionModel>> getAll();
  Future<List<PermissionModel>> getForUser(int userId);
  Future<PermissionModel> create({required String name, String? description});
  Future<void> assign({required int userId, required int permissionId});
  Future<void> revoke({required int userId, required int permissionId});
}

class PermissionsRemoteDataSourceImpl implements PermissionsRemoteDataSource {
  final Dio dio;
  PermissionsRemoteDataSourceImpl(this.dio);

  @override
  Future<List<PermissionModel>> getAll() async {
    try {
      final response = await dio.get(ApiConstants.permissions);
      return _parseList(response.data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<PermissionModel>> getForUser(int userId) async {
    try {
      final response = await dio.get(ApiConstants.permissionsForUser(userId));
      return _parseList(response.data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<PermissionModel> create({required String name, String? description}) async {
    try {
      final response = await dio.post(
        ApiConstants.permissions,
        data: {
          'name': name,
          if (description != null && description.trim().isNotEmpty)
            'description': description.trim(),
        },
      );
      return PermissionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> assign({required int userId, required int permissionId}) async {
    try {
      await dio.post(
        ApiConstants.assignPermission,
        data: {'userId': userId, 'permissionId': permissionId},
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> revoke({required int userId, required int permissionId}) async {
    try {
      await dio.post(
        ApiConstants.revokePermission,
        data: {'userId': userId, 'permissionId': permissionId},
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  List<PermissionModel> _parseList(dynamic data) {
    if (data is! List) {
      throw ServerException('Invalid permissions response');
    }
    return data
        .map((item) => PermissionModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Exception _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException();
    }
    final status = e.response?.statusCode;
    final message = _responseMessage(e);
    if (status == 400) return ValidationException(message);
    if (status == 403) return ForbiddenException(message);
    if (status == 404) return NotFoundException(message);
    if (status == 409) return ConflictException(message);
    return ServerException(message);
  }

  String _responseMessage(DioException e) {
    final data = e.response?.data;
    if (data is String && data.trim().isNotEmpty) return data;
    if (data is Map<String, dynamic>) {
      for (final key in ['message', 'title', 'detail', 'error']) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) return value;
      }
    }
    return e.message ?? 'Server error';
  }
}
