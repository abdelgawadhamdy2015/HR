// lib/features/auth/data/models/auth_user_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/auth_user.dart';

part 'auth_user_model.g.dart';

@JsonSerializable()
class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.permissions,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) =>
      _$AuthUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthUserModelToJson(this);
}
