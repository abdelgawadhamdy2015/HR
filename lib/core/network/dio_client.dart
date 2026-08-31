import 'package:dio/dio.dart';
import 'api_constants.dart';
import 'auth_interceptor.dart';
import '../storage/token_storage.dart';

/// Thin wrapper around Dio, configured once and injected everywhere via GetIt.
class DioClient {
  final Dio dio;

  DioClient({TokenStorage? tokenStorage})
      : dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: ApiConstants.connectTimeout,
            receiveTimeout: ApiConstants.receiveTimeout,
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
    // Attaches the stored JWT (if any) to every outgoing request.
    dio.interceptors.add(AuthInterceptor(tokenStorage ?? TokenStorage()));

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }
}
