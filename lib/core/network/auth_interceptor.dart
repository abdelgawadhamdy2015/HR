import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

/// Attaches `Authorization: Bearer <token>` to every outgoing request when a
/// token is present. Register this on the shared Dio instance in DioClient.
class AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;

  AuthInterceptor(this.tokenStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await tokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Hook point: if the backend returns 401, the token is invalid/expired.
    // Wire this to your AuthProvider (e.g. via a callback or an event bus)
    // if you want an automatic forced-logout on 401.
    handler.next(err);
  }
}
