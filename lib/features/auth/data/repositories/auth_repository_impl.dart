import 'package:dio/dio.dart';
import 'package:hr_attendance_app/features/auth/data/models/auth_request_models.dart';
import 'package:hr_attendance_app/features/auth/data/models/auth_response_model.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource datasource;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl({required this.datasource, required this.tokenStorage});

  @override
  Future<AuthResponseModel> login({required LoginRequest request}) async {
    try {
      final result = await datasource.login(request);
      await tokenStorage.saveToken(result.token ?? "");
      return result;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<AuthResponseModel> register({required RegisterRequest request}) async {
    try {
      final result = await datasource.register(request);
      await tokenStorage.saveToken(result.token ?? "");
      return result;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> logout() => tokenStorage.clearToken();

  @override
  Future<bool> isLoggedIn() async {
    final token = await tokenStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    if (!await isLoggedIn()) return null;
    try {
      final data = await datasource.me();
      return AuthUser(
        id: data.id,
        username: data.username,
        email: data.email,
        permissions: data.permissions,
      );
    } on DioException {
      // Token expired/invalid — treat as logged out rather than throwing.
      await tokenStorage.clearToken();
      return null;
    }
  }

  Exception _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return Exception(data['message'].toString());
    }
    if (data is String && data.isNotEmpty) {
      return Exception(data);
    }
    if (e.response?.statusCode == 401) {
      return Exception('Invalid username or password.');
    }
    if (e.response?.statusCode == 409) {
      return Exception('A user with this username or email already exists.');
    }
    return Exception(e.message ?? 'Network error, please try again.');
  }
}
