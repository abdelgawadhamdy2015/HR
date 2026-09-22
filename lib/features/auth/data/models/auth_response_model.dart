import 'package:hr_attendance_app/features/auth/domain/entities/auth_user.dart'
    show AuthUser;
import 'package:json_annotation/json_annotation.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel {
  final int? userId;
  final String? username;
  final String? email;
  final String? token;
  final DateTime? expiresAt;
  final List<String>? permissions;

  const AuthResponseModel({
    this.userId,
    this.username,
    this.email,
    this.token,
    this.expiresAt,
    this.permissions,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);

  AuthUser toEntity() {
    return AuthUser(
      id: userId ?? 0,
      username: username ?? '',
      email: email ?? '',
      permissions: permissions ?? const [],
    );
  }
}
