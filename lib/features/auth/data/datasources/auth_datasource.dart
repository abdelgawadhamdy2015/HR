import 'package:dio/dio.dart';
import 'package:hr_attendance_app/features/auth/data/models/auth_request_models.dart';
import 'package:hr_attendance_app/features/auth/data/models/auth_user_model.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/network/api_constants.dart';
import '../models/auth_response_model.dart';

part 'auth_datasource.g.dart';

@RestApi()
abstract class AuthDataSource {
  factory AuthDataSource(Dio dio, {String baseUrl}) = _AuthDataSource;

  @POST(ApiConstants.login)
  Future<AuthResponseModel> login(
    @Body() LoginRequest request,
  );

  @POST(ApiConstants.register)
  Future<AuthResponseModel> register(
    @Body() RegisterRequest request,
  );

  @GET(ApiConstants.me)
  Future<AuthUserModel> me();
}
