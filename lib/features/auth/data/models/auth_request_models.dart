import 'package:json_annotation/json_annotation.dart';

part 'auth_request_models.g.dart';

@JsonSerializable(createFactory: false)
class LoginRequest {
  final String username;
  final String password;

    const LoginRequest({
        required this.username,
        required this.password,
    });

    Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String fullName;

    const RegisterRequest({
        required this.username,
        required this.email,
        required this.password,
        required this.fullName,
    });

    Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}